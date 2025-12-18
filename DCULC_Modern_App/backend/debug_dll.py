import ctypes
import sys
import os

dll_path = r"e:\BACKUP_MSATA\DCULC\Windows.dll\dculc.dll"

print(f"Python Version: {sys.version}")
print(f"Checking DLL at: {dll_path}")

if not os.path.exists(dll_path):
    print("ERROR: DLL file does not exist at specified path!")
    sys.exit(1)

try:
    dll = ctypes.windll.LoadLibrary(dll_path)
    print("SUCCESS: DLL loaded successfully.")
    
    # Try to access a function
    print("Checking IC_InitComm...")
    print(dll.IC_InitComm)
    
except Exception as e:
    print(f"ERROR Loading DLL: {e}")
    import traceback
    traceback.print_exc()

import platform
print(f"Architecture: {platform.architecture()}")
