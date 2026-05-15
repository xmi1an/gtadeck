"""
Build script to create standalone executable for GTADeck Desktop Companion
"""
import PyInstaller.__main__
import os
import sys

def build():
    """Build the executable"""

    # PyInstaller arguments
    args = [
        'gui_app.py',
        '--name=GTADeck',
        '--onefile',
        '--windowed',
        '--icon=NONE',
        '--exclude-module=numpy',
        '--exclude-module=pandas',
        '--exclude-module=matplotlib',
        '--exclude-module=scipy',
        '--exclude-module=PIL',
        '--exclude-module=Pillow',
        '--exclude-module=pystray',
        '--noupx',
        '--clean',
        '--noconfirm',
    ]

    print("Building GTADeck Desktop Companion executable...")
    print("This may take a few minutes...\n")

    try:
        PyInstaller.__main__.run(args)
        print("\n" + "="*60)
        print("Build completed successfully!")
        print("="*60)
        print("\nExecutable location: dist/GTADeck.exe")
        print("\nYou can now distribute this single .exe file to users.")
        print("No Python installation required on target machines!")

    except Exception as e:
        print(f"\nBuild failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    build()
