# GTADeck - GTA V Mobile Companion App

A premium Flutter mobile companion app that connects to your PC while playing Grand Theft Auto V, allowing you to trigger immersive in-game shortcuts and macros from your phone in real-time.

![GTADeck](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)
![Python](https://img.shields.io/badge/Python-3.8+-yellow)

## 🎮 Features

- **Real-time PC Connection**: WebSocket-based communication with <100ms latency
- **GTA V-Inspired UI**: Cinematic, futuristic design that feels like your character's smartphone
- **Pre-configured Commands**: Quick access to common GTA V actions
- **Custom Macros**: Execute complex key sequences with a single tap
- **Haptic Feedback**: Immersive tactile response on command execution
- **Connection Status**: Real-time monitoring with latency display
- **Safe & Legitimate**: Quality-of-life tool that doesn't violate game policies

## 📱 Command Categories

### Quick Actions
- 🗺️ **Map** - Open game map (M key)
- 📱 **Phone** - Open in-game phone (Up arrow)
- 🎮 **Interaction Menu** - Access interaction menu
- 📍 **Quick GPS** - Set GPS waypoint

### Vehicle
- 🔧 **Call Mechanic** - Request vehicle delivery
- 🚗 **Request Vehicle** - Summon personal vehicle
- 🅿️ **Return Vehicle** - Send vehicle to storage

### Character
- 🍔 **Eat Snack** - Restore health
- 🛡️ **Armor** - Use armor
- ☮️ **Passive Mode** - Toggle passive mode

### Utility
- 💾 **Quick Save** - Save game progress
- 📸 **Screenshot** - Capture screenshot
- 🎬 **Record** - Start/stop recording

## 🏗️ Architecture

### Three-Tier System

1. **Flutter Mobile App** (Android/iOS)
   - GTA V-inspired UI with neon glow effects
   - Real-time WebSocket connection
   - State management with Riverpod
   - Haptic feedback and animations

2. **Desktop Companion** (Windows)
   - Modern GUI application with system tray support
   - Python WebSocket server
   - Keyboard input simulation with auto-focus
   - Real-time connection monitoring
   - One-click start/stop server

3. **Communication Protocol**
   - WebSocket (ws://[PC_IP]:8080)
   - JSON message format
   - Auto-reconnect on disconnect
   - Heartbeat/ping mechanism

## 🚀 Getting Started

### Prerequisites

**Mobile App:**
- Android 5.0+ or iOS 12.0+
- Flutter SDK 3.10+

**Desktop Server:**
- Windows 10/11
- Python 3.8+
- GTA V installed

### Installation

#### 1. Desktop Server Setup

**Option A: Pre-built Executable (Recommended for Users)**

1. Download `GTADeck.exe` from the [releases page](https://github.com/xmi1an/gtadeck/releases)
2. Double-click to run the application
3. Click **"Start Server"** in the GUI window
4. Note your PC's IP address displayed in the app
5. If Windows Firewall prompts, click **"Allow access"**

**Option B: Run from Source (For Developers)**

```bash
cd desktop_companion
pip install -r requirements.txt
python gui_app.py
```

The GUI will display your PC's IP address. Keep this running while playing GTA V.

#### 2. Mobile App Setup

```bash
# Install dependencies
flutter pub get

# Run on Android
flutter run

# Build APK
flutter build apk
```

#### 3. Connect

1. Launch the desktop server on your PC
2. Open GTADeck on your phone
3. Enter your PC's IP address (e.g., 192.168.1.100)
4. Tap **CONNECT**
5. Start GTA V and control it from your phone!

## 📂 Project Structure

```
gtadeck/
├── lib/
│   ├── core/
│   │   ├── theme/           # GTA V-inspired theme
│   │   └── constants/       # App constants
│   ├── models/              # Data models
│   ├── services/            # WebSocket & storage services
│   ├── providers/           # Riverpod state management
│   ├── screens/             # UI screens
│   └── widgets/             # Reusable widgets
├── desktop_companion/
│   ├── gui_app.py          # GUI application (main)
│   ├── server.py           # WebSocket server (legacy CLI)
│   ├── build_exe.py        # Executable builder
│   ├── requirements.txt    # Python dependencies
│   └── README.md           # Server documentation
└── android/                # Android configuration
```

## 🎨 Design System

### Color Palette
- **Primary**: Neon Green (#00FF41) - GTA V signature color
- **Secondary**: Electric Blue (#00D7FF)
- **Health**: Green (#4ADE80)
- **Armor**: Blue (#3B82F6)
- **Danger**: Red (#EF4444)
- **Background**: Dark (#0A0E1A)

### Typography
- **Headers**: Orbitron (futuristic, bold)
- **Body**: Rajdhani (clean, readable)
- **UI Elements**: Roboto (standard)

## 🔒 Security & Safety

- ✅ **Local network only** - No internet exposure
- ✅ **Keyboard simulation only** - No game memory manipulation
- ✅ **No file system access** - Safe and sandboxed
- ✅ **Legitimate use** - Quality-of-life tool, not cheating
- ✅ **Rockstar compliant** - Doesn't violate terms of service

## 🛠️ Development

### Tech Stack

**Mobile:**
- Flutter 3.10+
- Riverpod (state management)
- WebSocket Channel (networking)
- Google Fonts (typography)
- Shared Preferences (storage)

**Desktop:**
- Python 3.8+
- tkinter (GUI interface)
- websockets (WebSocket server)
- pynput (keyboard simulation)
- pywin32 (Windows integration)
- pystray (system tray support)

### Running in Development

```bash
# Hot reload
flutter run

# Run with specific device
flutter run -d <device_id>

# Check for issues
flutter doctor
```

## 📝 Message Protocol

### Command Format
```json
{
  "type": "command",
  "action": "keyboard_press",
  "payload": {
    "key": "M"
  },
  "timestamp": 1234567890
}
```

### Response Format
```json
{
  "type": "response",
  "status": "success",
  "message": "Command executed"
}
```

### Heartbeat
```json
{
  "type": "ping",
  "timestamp": 1234567890
}
```

## 🐛 Troubleshooting

### Connection Issues

**Can't connect to PC:**
- Verify both devices are on the same WiFi network
- Check Windows Firewall settings
- Ensure server is running on PC
- Try disabling VPN

**High latency:**
- Use 5GHz WiFi instead of 2.4GHz
- Move closer to router
- Close bandwidth-heavy apps

**Commands not working:**
- Make sure GTA V window is focused
- Verify game is running
- Check key bindings in GTA V settings

### Build Issues

**Android build fails:**
- Run `flutter clean`
- Delete `android/.gradle` folder
- Run `flutter pub get`
- Rebuild

**Missing dependencies:**
- Run `flutter pub get`
- Check pubspec.yaml for errors

## 🚧 Future Enhancements

- [ ] Custom macro builder
- [ ] Command profiles (Story Mode vs Online)
- [ ] Voice commands
- [ ] Game state display (health, armor, wanted level)
- [ ] Vehicle spawner with model selection
- [ ] Weapon wheel quick access
- [ ] Radio station control
- [ ] iOS version
- [ ] Tablet-optimized layout

## 📄 License

This project is for educational and personal use only. GTA V and all related trademarks are property of Rockstar Games.

## ⚠️ Disclaimer

GTADeck is a quality-of-life companion tool designed for legitimate gameplay enhancement. It does not provide unfair advantages, manipulate game memory, or violate Rockstar Games' terms of service. Use responsibly and in accordance with game policies.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📧 Support

For issues and questions, please open an issue on GitHub.

---

**Made with ❤️ for the GTA V community**
