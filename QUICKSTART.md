# GTADeck Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Install Desktop Server (2 minutes)

1. Open Command Prompt or PowerShell
2. Navigate to the desktop_companion folder:
   ```bash
   cd desktop_companion
   ```
3. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Start the server:
   ```bash
   python server.py
   ```
5. **Note your PC's IP address** displayed in the console (e.g., 192.168.1.100)

### Step 2: Build Mobile App (2 minutes)

1. Open terminal in the project root
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Connect your Android device or start an emulator
4. Run the app:
   ```bash
   flutter run
   ```
   Or build an APK:
   ```bash
   flutter build apk
   ```

### Step 3: Connect & Play (1 minute)

1. Open GTADeck on your phone
2. Enter your PC's IP address from Step 1
3. Tap **CONNECT**
4. Launch GTA V on your PC
5. Start using commands from your phone!

## 📱 First Commands to Try

1. **Map (🗺️)** - Opens the game map
2. **Phone (📱)** - Opens your in-game phone
3. **Quick Save (💾)** - Saves your game

## ⚠️ Common Issues

### "Connection refused"
- Make sure the desktop server is running
- Check that both devices are on the same WiFi network
- Disable VPN if active

### "Commands not working"
- Make sure GTA V window is focused (click on the game)
- Verify the game is running

### "Can't find IP address"
Run this in Command Prompt:
```bash
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter.

## 🎮 Tips for Best Experience

- Use 5GHz WiFi for lower latency
- Keep phone and PC close to router
- Run server before starting GTA V
- Keep GTA V window focused when using commands

## 🔥 Pro Tips

- Commands execute instantly with <100ms latency
- You can spam buttons - the app handles rapid commands
- Macros execute automatically with proper delays
- Connection survives brief network hiccups

## 📞 Need Help?

Check the main README.md for detailed troubleshooting and documentation.

---

**Enjoy your enhanced GTA V experience! 🎮**
