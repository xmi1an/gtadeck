# GTADeck Desktop Companion - User Guide

## What is GTADeck?

GTADeck lets you control GTA V from your phone. This desktop app runs on your Windows PC and receives commands from the GTADeck mobile app.

## Installation

### Option 1: Download Executable (Recommended for Non-Technical Users)

1. Download `GTADeck.exe`
2. Double-click to run
3. That's it! No installation needed.

### Option 2: Run from Source (For Developers)

1. Make sure Python 3.8+ is installed
2. Double-click `run.bat`
3. The app will install dependencies and start automatically

## How to Use

### First Time Setup

1. **Start the app** - Double-click GTADeck.exe or run.bat
2. **Click "Start Server"** - The green button in the app
3. **Note your IP address** - It's shown in the gray box (e.g., 192.168.1.100)
4. **Allow through firewall** - Windows may ask for permission, click "Allow"

### Connecting Your Phone

1. **Open GTADeck app** on your phone
2. **Enter your PC's IP address** (from step 3 above)
3. **Connect** - You should see "Connected: 1 client(s)" in the desktop app
4. **Start GTA V** and play!

### Running in Background

- You can minimize the window normally (minimize button)
- The app will keep running in the background
- Just don't close the window while playing

## Troubleshooting

### Phone Can't Connect

**Problem:** Mobile app says "Connection failed"

**Solutions:**
1. Make sure both PC and phone are on the same WiFi network
2. Check if Windows Firewall is blocking the app:
   - Open Windows Security
   - Go to Firewall & network protection
   - Click "Allow an app through firewall"
   - Find GTADeck and check both Private and Public boxes
3. Try restarting the server (Stop → Start)

### Commands Not Working in Game

**Problem:** Phone connects but keys don't work in GTA V

**Solutions:**
1. Make sure GTA V is running (not minimized)
2. The app auto-focuses the game window - give it a second
3. Check your GTA V key bindings match what you're sending

### Server Won't Start

**Problem:** "Start Server" button doesn't work

**Solutions:**
1. Port 8080 might be in use - close other apps
2. Try running as Administrator (right-click → Run as administrator)
3. Check if antivirus is blocking the app

### High Latency/Lag

**Problem:** Commands are delayed

**Solutions:**
1. Use 5GHz WiFi instead of 2.4GHz
2. Move closer to your WiFi router
3. Close bandwidth-heavy apps (streaming, downloads)

## Tips

- **Keep the app running** - Minimize to tray instead of closing
- **Start before gaming** - Launch the app before starting GTA V
- **Check connection count** - Make sure only your phone is connected
- **Firewall is important** - Always allow the app through Windows Firewall

## Safety & Terms

- This app only simulates keyboard input
- No game memory manipulation
- No unfair advantages
- Safe for single-player and multiplayer
- Like using a macro keyboard or Stream Deck
- Does not violate Rockstar's terms of service

## Need Help?

If you're still having issues:
1. Check the README.md file for technical details
2. Make sure you're using the latest version
3. Report issues on GitHub

---

**Enjoy controlling GTA V from your phone!** 🎮📱
