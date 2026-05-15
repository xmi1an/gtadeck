# Distribution Package - GTADeck Desktop Companion

## What You Get

**File:** `dist/GTADeck.exe` (31 MB)

This is a **standalone executable** - no Python or dependencies needed!

## How to Distribute

### Option 1: Direct Share
Simply share the `GTADeck.exe` file from the `dist` folder with your users.

### Option 2: Create a Release Package
1. Copy `GTADeck.exe` from `dist/` folder
2. Include `USER_GUIDE.md` for instructions
3. Zip them together
4. Share the zip file

## What Users Need to Do

1. **Download** `GTADeck.exe`
2. **Double-click** to run
3. **Allow through Windows Firewall** (if prompted)
4. **Click "Start Server"**
5. **Connect from mobile app** using the IP shown

That's it! No installation, no Python, no technical knowledge required.

## Important Notes

### First Run
- Windows Defender may show a warning (because the .exe is unsigned)
- Users should click "More info" → "Run anyway"
- This is normal for unsigned executables

### Firewall
- Windows will ask to allow network access
- Users must click "Allow" for the app to work
- This only happens once

### File Size
- The .exe is 31 MB because it includes:
  - Python runtime
  - All libraries (websockets, pynput, PIL, etc.)
  - GUI framework (tkinter)
  - Everything needed to run

### System Requirements
- Windows 10 or 11
- No other requirements!

## Testing Before Distribution

Test the executable on a clean Windows machine (without Python) to ensure:
1. It launches without errors
2. Server starts successfully
3. Mobile app can connect
4. Commands work in GTA V

## Signing the Executable (Optional)

To remove Windows Defender warnings, you can:
1. Get a code signing certificate
2. Sign the .exe with `signtool`
3. This costs money but makes it more professional

For personal/friend use, unsigned is fine - users just need to click "Run anyway" once.

---

**Your users now have a one-click solution!** 🎉
