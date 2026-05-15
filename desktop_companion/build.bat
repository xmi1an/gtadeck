@echo off
echo ========================================
echo Building GTADeck Executable
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo.
    echo Please install Python 3.8 or higher from:
    echo https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Python found!
echo.

REM Check if PyInstaller is installed
pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo PyInstaller not found. Installing...
    pip install pyinstaller
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install PyInstaller!
        pause
        exit /b 1
    )
)

echo.
echo Building executable...
echo This may take a few minutes...
echo.

REM Run the build script
python build_exe.py

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo The executable is located at: dist\GTADeck.exe
echo.
echo You can now distribute this file to users.
echo No Python installation required!
echo.
pause
