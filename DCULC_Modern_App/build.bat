@echo off
echo Installing dependencies...
python -m pip install pyinstaller waitress

echo.
echo Building DCULC Pro Reader...
echo This may take a minute.

rem Clean build directories
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

rem Run PyInstaller
rem --name: Output Name
rem --onefile: Single EXE
rem --windowed: No console window (optional, good for release)
rem --add-data: Bundle frontend assets
rem --add-binary: Bundle DLL
rem --icon: (Optional, skipping for now)

PyInstaller --name DCULC_Reader --clean --noconfirm --onefile --hidden-import=waitress --add-data "frontend;frontend" --add-binary "e:\BACKUP_MSATA\DCULC\Windows.dll\dculc.dll;." backend/app.py

echo.
if exist dist\DCULC_Reader.exe (
    echo Build Successful! 
    echo Executable is located in: %~dp0dist\DCULC_Reader.exe
) else (
    echo Build Failed. Check the output above.
)
pause
