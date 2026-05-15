import asyncio
import websockets
import json
import logging
import time
import threading
import tkinter as tk
from tkinter import ttk
from pynput.keyboard import Controller, Key
from datetime import datetime
import pygetwindow as gw
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Keyboard controller
keyboard = Controller()

# Key mapping for special keys
KEY_MAP = {
    'Up': Key.up,
    'Down': Key.down,
    'Left': Key.left,
    'Right': Key.right,
    'Enter': Key.enter,
    'Space': Key.space,
    'Esc': Key.esc,
    'Tab': Key.tab,
    'Shift': Key.shift,
    'Ctrl': Key.ctrl,
    'Alt': Key.alt,
    'F1': Key.f1,
    'F2': Key.f2,
    'F3': Key.f3,
    'F4': Key.f4,
    'F5': Key.f5,
    'F6': Key.f6,
    'F7': Key.f7,
    'F8': Key.f8,
    'F9': Key.f9,
    'F10': Key.f10,
    'F11': Key.f11,
    'F12': Key.f12,
}

# Connected clients
connected_clients = set()

# GTA V window cache
gta_window = None
last_window_check = 0

# Server state
server_running = False
websocket_server = None

def find_gta_window():
    """Find and cache the GTA V window"""
    global gta_window, last_window_check

    current_time = time.time()
    if gta_window and current_time - last_window_check < 5:
        return gta_window

    last_window_check = current_time

    try:
        windows = gw.getAllTitles()
        for title in windows:
            if 'Grand Theft Auto V' in title or 'GTA V' in title or 'GTAV' in title:
                gta_window = gw.getWindowsWithTitle(title)[0]
                logger.info(f"Found GTA V window: {title}")
                return gta_window

        gta_window = None
        return None
    except Exception as e:
        logger.error(f"Error finding GTA V window: {e}")
        return None

def focus_gta_window():
    """Bring GTA V window to focus"""
    try:
        window = find_gta_window()
        if window:
            if window.isMinimized:
                window.restore()
            window.activate()
            time.sleep(0.05)
            return True
        return False
    except Exception as e:
        logger.warning(f"Could not focus GTA V window: {e}")
        return False

def press_key(key_name):
    """Press and release a key"""
    try:
        focus_gta_window()

        if key_name in KEY_MAP:
            key = KEY_MAP[key_name]
        else:
            key = key_name.lower()

        keyboard.press(key)
        time.sleep(0.05)
        keyboard.release(key)
        logger.info(f"Pressed key: {key_name}")
        return True
    except Exception as e:
        logger.error(f"Error pressing key {key_name}: {e}")
        return False

def hold_key(key_name, duration_ms):
    """Hold a key for specified duration"""
    try:
        focus_gta_window()

        if key_name in KEY_MAP:
            key = KEY_MAP[key_name]
        else:
            key = key_name.lower()

        keyboard.press(key)
        time.sleep(duration_ms / 1000.0)
        keyboard.release(key)
        logger.info(f"Held key {key_name} for {duration_ms}ms")
        return True
    except Exception as e:
        logger.error(f"Error holding key {key_name}: {e}")
        return False

async def execute_macro(steps):
    """Execute a sequence of key presses"""
    try:
        focus_gta_window()

        for step in steps:
            key = step.get('key')
            delay = step.get('delay', 0)
            hold = step.get('hold', 0)

            if hold > 0:
                hold_key(key, hold)
            else:
                press_key(key)

            if delay > 0:
                await asyncio.sleep(delay / 1000.0)

        logger.info(f"Executed macro with {len(steps)} steps")
        return True
    except Exception as e:
        logger.error(f"Error executing macro: {e}")
        return False

async def handle_command(websocket, message):
    """Handle incoming command from mobile app"""
    try:
        data = json.loads(message)
        command_type = data.get('type')

        if command_type == 'ping':
            await websocket.send(json.dumps({
                'type': 'pong',
                'timestamp': data.get('timestamp')
            }))
            return

        if command_type == 'command':
            action = data.get('action')
            payload = data.get('payload', {})

            success = False

            if action == 'keyboard_press':
                key = payload.get('key')
                success = press_key(key)

            elif action == 'keyboard_hold':
                key = payload.get('key')
                duration = payload.get('duration', 1000)
                success = hold_key(key, duration)

            elif action == 'macro':
                steps = payload.get('steps', [])
                success = await execute_macro(steps)

            await websocket.send(json.dumps({
                'type': 'response',
                'status': 'success' if success else 'error',
                'message': 'Command executed' if success else 'Command failed'
            }))

    except json.JSONDecodeError:
        logger.error("Invalid JSON received")
        await websocket.send(json.dumps({
            'type': 'response',
            'status': 'error',
            'message': 'Invalid JSON'
        }))
    except Exception as e:
        logger.error(f"Error handling command: {e}")
        await websocket.send(json.dumps({
            'type': 'response',
            'status': 'error',
            'message': str(e)
        }))

async def handle_client(websocket, path, app):
    """Handle WebSocket client connection"""
    client_address = websocket.remote_address
    logger.info(f"Client connected: {client_address}")
    connected_clients.add(websocket)

    app.update_status(f"Connected: {len(connected_clients)} client(s)")

    try:
        window = find_gta_window()
        game_running = window is not None

        await websocket.send(json.dumps({
            'type': 'status',
            'connected': True,
            'game_running': game_running,
            'message': 'Connected to GTADeck Server'
        }))

        async for message in websocket:
            await handle_command(websocket, message)

    except websockets.exceptions.ConnectionClosed:
        logger.info(f"Client disconnected: {client_address}")
    except Exception as e:
        logger.error(f"Error with client {client_address}: {e}")
    finally:
        connected_clients.discard(websocket)
        app.update_status(f"Connected: {len(connected_clients)} client(s)")

class GTADeckApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("GTADeck Desktop Companion")
        self.root.geometry("400x300")
        self.root.resizable(False, False)

        # Server state
        self.server_running = False
        self.server_task = None
        self.loop = None

        # Setup UI
        self.setup_ui()

        # Handle window close
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)

    def setup_ui(self):
        """Setup the GUI"""
        # Header
        header_frame = tk.Frame(self.root, bg="#2c3e50", height=60)
        header_frame.pack(fill=tk.X)
        header_frame.pack_propagate(False)

        title_label = tk.Label(
            header_frame,
            text="GTADeck Desktop Companion",
            font=("Arial", 16, "bold"),
            bg="#2c3e50",
            fg="white"
        )
        title_label.pack(pady=15)

        # Main content
        content_frame = tk.Frame(self.root, bg="white")
        content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        # Status section
        status_label = tk.Label(
            content_frame,
            text="Server Status:",
            font=("Arial", 10, "bold"),
            bg="white"
        )
        status_label.pack(anchor=tk.W)

        self.status_text = tk.Label(
            content_frame,
            text="● Stopped",
            font=("Arial", 12),
            bg="white",
            fg="#e74c3c"
        )
        self.status_text.pack(anchor=tk.W, pady=(5, 15))

        # Connection info
        self.connection_label = tk.Label(
            content_frame,
            text="Connected: 0 client(s)",
            font=("Arial", 10),
            bg="white",
            fg="#7f8c8d"
        )
        self.connection_label.pack(anchor=tk.W, pady=(0, 15))

        # IP Address info
        ip_frame = tk.Frame(content_frame, bg="#ecf0f1", relief=tk.SOLID, borderwidth=1)
        ip_frame.pack(fill=tk.X, pady=(0, 15))

        ip_label = tk.Label(
            ip_frame,
            text="Your PC IP Address:",
            font=("Arial", 9),
            bg="#ecf0f1",
            fg="#7f8c8d"
        )
        ip_label.pack(anchor=tk.W, padx=10, pady=(5, 0))

        self.ip_text = tk.Label(
            ip_frame,
            text=self.get_local_ip(),
            font=("Arial", 12, "bold"),
            bg="#ecf0f1",
            fg="#2c3e50"
        )
        self.ip_text.pack(anchor=tk.W, padx=10, pady=(0, 5))

        # Control buttons
        button_frame = tk.Frame(content_frame, bg="white")
        button_frame.pack(fill=tk.X, pady=(10, 0))

        self.start_button = tk.Button(
            button_frame,
            text="Start Server",
            command=self.toggle_server,
            font=("Arial", 11, "bold"),
            bg="#27ae60",
            fg="white",
            activebackground="#229954",
            activeforeground="white",
            relief=tk.FLAT,
            cursor="hand2",
            height=2
        )
        self.start_button.pack(fill=tk.X)

        # Footer info
        footer_label = tk.Label(
            button_frame,
            text="Keep this window open while playing",
            font=("Arial", 8),
            bg="white",
            fg="#7f8c8d"
        )
        footer_label.pack(pady=(10, 0))

    def get_local_ip(self):
        """Get local IP address"""
        import socket
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "Unable to detect"

    def update_status(self, connection_text=None):
        """Update status display"""
        if self.server_running:
            self.status_text.config(text="● Running", fg="#27ae60")
            self.start_button.config(text="Stop Server", bg="#e74c3c", activebackground="#c0392b")
        else:
            self.status_text.config(text="● Stopped", fg="#e74c3c")
            self.start_button.config(text="Start Server", bg="#27ae60", activebackground="#229954")

        if connection_text:
            self.connection_label.config(text=connection_text)

    def toggle_server(self):
        """Start or stop the server"""
        if self.server_running:
            self.stop_server()
        else:
            self.start_server()

    def start_server(self):
        """Start the WebSocket server"""
        self.server_running = True
        self.update_status("Connected: 0 client(s)")

        # Start server in background thread
        server_thread = threading.Thread(target=self.run_server, daemon=True)
        server_thread.start()

        logger.info("Server started")

    def run_server(self):
        """Run the WebSocket server"""
        self.loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self.loop)

        async def serve():
            async with websockets.serve(
                lambda ws, path: handle_client(ws, path, self),
                "0.0.0.0",
                8080
            ):
                await asyncio.Future()

        try:
            self.loop.run_until_complete(serve())
        except Exception as e:
            logger.error(f"Server error: {e}")

    def stop_server(self):
        """Stop the WebSocket server"""
        self.server_running = False
        self.update_status("Connected: 0 client(s)")

        if self.loop:
            self.loop.call_soon_threadsafe(self.loop.stop)

        logger.info("Server stopped")

    def on_closing(self):
        """Handle window close event"""
        if self.server_running:
            self.stop_server()
        self.root.quit()
        sys.exit(0)

    def run(self):
        """Run the application"""
        self.root.mainloop()

if __name__ == "__main__":
    app = GTADeckApp()
    app.run()
