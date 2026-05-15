import asyncio
import websockets
import json
import logging
import time
from pynput.keyboard import Controller, Key
from datetime import datetime
import pygetwindow as gw

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

def find_gta_window():
    """Find and cache the GTA V window"""
    global gta_window, last_window_check

    current_time = time.time()
    # Only check for window every 5 seconds to avoid performance issues
    if gta_window and current_time - last_window_check < 5:
        return gta_window

    last_window_check = current_time

    try:
        # Try to find GTA V window by common titles
        windows = gw.getAllTitles()
        for title in windows:
            if 'Grand Theft Auto V' in title or 'GTA V' in title or 'GTAV' in title:
                gta_window = gw.getWindowsWithTitle(title)[0]
                logger.info(f"Found GTA V window: {title}")
                return gta_window

        logger.warning("GTA V window not found")
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
            time.sleep(0.05)  # Small delay to ensure focus
            return True
        return False
    except Exception as e:
        logger.warning(f"Could not focus GTA V window: {e}")
        return False

def press_key(key_name):
    """Press and release a key"""
    try:
        # Try to focus GTA V window first
        focus_gta_window()

        if key_name in KEY_MAP:
            key = KEY_MAP[key_name]
        else:
            key = key_name.lower()

        keyboard.press(key)
        time.sleep(0.05)  # Small delay between press and release
        keyboard.release(key)
        logger.info(f"Pressed key: {key_name}")
        return True
    except Exception as e:
        logger.error(f"Error pressing key {key_name}: {e}")
        return False

def hold_key(key_name, duration_ms):
    """Hold a key for specified duration"""
    try:
        # Try to focus GTA V window first
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
        # Try to focus GTA V window first
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
            # Respond to heartbeat
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

            # Send response
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

async def handle_client(websocket, path):
    """Handle WebSocket client connection"""
    client_address = websocket.remote_address
    logger.info(f"Client connected: {client_address}")
    connected_clients.add(websocket)

    try:
        # Check for GTA V window on connection
        window = find_gta_window()
        game_running = window is not None

        # Send welcome message
        await websocket.send(json.dumps({
            'type': 'status',
            'connected': True,
            'game_running': game_running,
            'message': 'Connected to GTADeck Server'
        }))

        # Listen for messages
        async for message in websocket:
            await handle_command(websocket, message)

    except websockets.exceptions.ConnectionClosed:
        logger.info(f"Client disconnected: {client_address}")
    except Exception as e:
        logger.error(f"Error with client {client_address}: {e}")
    finally:
        connected_clients.discard(websocket)

async def main():
    """Start the WebSocket server"""
    host = "0.0.0.0"
    port = 8080

    logger.info(f"Starting GTADeck Server on {host}:{port}")
    logger.info("Waiting for mobile app connections...")
    logger.info("\nIMPORTANT: Make sure GTA V is running!")
    logger.info("The server will automatically focus the game window when you send commands.\n")

    async with websockets.serve(handle_client, host, port):
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Server error: {e}")
