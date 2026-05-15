# GTADeck Desktop Companion

Windows desktop application for GTADeck mobile app. Control GTA V from your phone with a simple, user-friendly interface.

## For Users (Non-Technical)

### Quick Start

1. **Download** `GTADeck.exe` from the releases
2. **Double-click** to run the application
3. **Click "Start Server"** in the window
4. **Note your PC's IP address** shown in the app
5. **Open GTADeck on your phone** and enter the IP address
6. **Start playing!**

### Firewall Setup

If your phone can't connect:
1. Windows may show a firewall prompt - click **"Allow access"**
2. Or manually: Windows Security → Firewall → Allow an app → Add GTADeck.exe

### System Tray

- Click **"Minimize to Tray"** to run in background
- Right-click the tray icon to show/exit

## For Developers

### Development Setup

1. Install Python 3.8+
2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the GUI app:
```bash
python gui_app.py
```

### Building Executable

1. Install PyInstaller:
```bash
pip install pyinstaller
```

2. Build the executable:
```bash
python build_exe.py
```

3. Find the executable in `dist/GTADeck.exe`

### Project Structure

```
desktop_companion/
├── gui_app.py          # Main GUI application
├── server.py           # Original CLI server (legacy)
├── build_exe.py        # Build script for executable
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

### Features

- **GUI Interface**: Clean, modern interface for non-technical users
- **System Tray**: Minimize to tray and run in background
- **Auto-focus**: Automatically focuses GTA V window when receiving commands
- **Connection Status**: Real-time display of connected clients
- **IP Display**: Shows local IP address for easy mobile setup
- **One-Click Start/Stop**: Simple server control

### Technical Details

**WebSocket Server:**
- Port: 8080
- Protocol: JSON-based messaging
- Commands: keyboard_press, keyboard_hold, macro

**Supported Commands:**
- Single key press
- Key hold with duration
- Macro sequences with delays

**Security:**
- Local network only (0.0.0.0:8080)
- No internet exposure
- Keyboard simulation only (safe, non-invasive)

### Troubleshooting

**"Server won't start":**
- Check if port 8080 is already in use
- Run as administrator if needed

**"Commands not working in game":**
- Make sure GTA V is running
- Verify game window is not minimized
- Check key bindings in GTA V settings

**"High latency":**
- Use 5GHz WiFi instead of 2.4GHz
- Reduce distance to router
- Close bandwidth-heavy applications

### Building for Distribution

The `build_exe.py` script creates a standalone executable that includes:
- Python runtime
- All dependencies
- GUI resources
- No installation required on target machines

Users just need to:
1. Download GTADeck.exe
2. Run it
3. Allow through firewall if prompted

## License

This is a quality-of-life tool for legitimate use. Does not violate Rockstar's terms of service - it simply simulates keyboard input like a macro keyboard or Stream Deck.
