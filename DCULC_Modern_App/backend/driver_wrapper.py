import ctypes
import os
import sys

# Define constants
IC_USB_PORT = 100

# Mapping of CheckCard return codes to Card Names (based on rDhelp.md)
CARD_TYPE_MAP = {
    1: "AT88SC102",
    2: "AT88SC1604",
    3: "AT88SC1604B",
    4: "AT88SC153",
    5: "AT88SC1608",
    6: "SLE4406",
    7: "SLE4404",
    8: "SLE4442",
    9: "SLE4428",
    11: "AT45D041",
    12: "SSF1101",
    21: "AT24C01A",
    22: "AT24C02",
    23: "AT24C04",
    24: "AT24C08",
    25: "AT24C16", # Extrapolated
    # Add more as needed
}

# Type codes for InitType (based on rDhelp.md)
TYPE_CODE_MAP = {
    "SLE4428": 0x04,
    "CPU": 0x0C,
    "SLE4442": 0x10,
    "AT24C01A": 0x40,
    "AT24C02": 0x40,
    "AT24C04": 0x40,
    "AT24C08": 0x40,
    "AT24C16": 0x40,
    "AT24C64": 0xC0
}

class DCULCDriver:
    def __init__(self, dll_path):
        self.dll_path = dll_path
        self.dll = None
        self.handle = -1
        self.current_type_id = 0 # Store current card type ID for write logic
        try:
            # Use stdcall convention for Windows DLL
            self.dll = ctypes.windll.LoadLibrary(self.dll_path)
            print(f"Loaded DLL from {self.dll_path}")
        except Exception as e:
            print(f"Failed to load DLL: {e}")
            raise

    def connect(self):
        if self.handle > 0:
            return True # Already connected
        
        # IC_InitComm
        # Prototype: HANDLE IC_InitComm(__int16 port)
        self.dll.IC_InitComm.argtypes = [ctypes.c_short]
        self.dll.IC_InitComm.restype = ctypes.c_void_p # HANDLE is usually void* or int. Treated as int for checking logic usually.

        ret = self.dll.IC_InitComm(IC_USB_PORT)
        if hasattr(ret, 'value'): # specialized types
             self.handle = ret.value
        else:
             self.handle = ret
        
        # Check if handle is valid (usually > 0)
        # Note: ctypes void_p might return None for 0.
        if self.handle and self.handle > 0:
            return True
        else:
            self.handle = -1
            return False

    def disconnect(self):
        if self.handle > 0:
            # IC_ExitComm
            self.dll.IC_ExitComm.argtypes = [ctypes.c_void_p]
            self.dll.IC_ExitComm(self.handle)
            self.handle = -1
            self.current_type_id = 0
            return True
        return False

    def check_status(self):
        if self.handle <= 0:
            return -1 # Not connected (custom error)
        
        # IC_Status
        self.dll.IC_Status.argtypes = [ctypes.c_void_p]
        self.dll.IC_Status.restype = ctypes.c_short
        
        return self.dll.IC_Status(self.handle)
        # Returns: 0=Card Present, 1=No Card, <0 Error

    def auto_detect(self):
        if self.handle <= 0:
            return {"success": False, "message": "Device not connected"}

        # 1. Try generic check
        self.dll.IC_CheckCard.argtypes = [ctypes.c_void_p]
        self.dll.IC_CheckCard.restype = ctypes.c_short
        
        code = self.dll.IC_CheckCard(self.handle)
        
        if code > 0:
            card_name = CARD_TYPE_MAP.get(code, f"Unknown (Code {code})")
            # Attempt to set type ID based on name map
            self.current_type_id = TYPE_CODE_MAP.get(card_name, 0)
            return {"success": True, "type": card_name, "method": "IC_CheckCard"}

        # 2. Try specific checks if generic failed or returned 0/error
        # Check CPU
        self.dll.IC_Check_CPU.argtypes = [ctypes.c_void_p]
        ret = self.dll.IC_Check_CPU(self.handle)
        if ret == 0: 
            self.current_type_id = TYPE_CODE_MAP.get("CPU", 0x0C)
            return {"success": True, "type": "CPU (T=0)", "method": "IC_Check_CPU"}
        if ret == 1: 
            self.current_type_id = TYPE_CODE_MAP.get("CPU", 0x0C)
            return {"success": True, "type": "CPU (T=1)", "method": "IC_Check_CPU"}

        # Check 24C64
        self.dll.IC_Check_24C64.argtypes = [ctypes.c_void_p]
        if self.dll.IC_Check_24C64(self.handle) == 0:
             self.current_type_id = TYPE_CODE_MAP.get("AT24C64", 0xC0)
             return {"success": True, "type": "AT24C64", "method": "IC_Check_24C64"}

        # Check 4442
        self.dll.IC_Check_4442.argtypes = [ctypes.c_void_p]
        if self.dll.IC_Check_4442(self.handle) == 0:
             self.current_type_id = TYPE_CODE_MAP.get("SLE4442", 0x10)
             return {"success": True, "type": "SLE4442", "method": "IC_Check_4442"}
        
        # Check 4428
        self.dll.IC_Check_4428.argtypes = [ctypes.c_void_p]
        if self.dll.IC_Check_4428(self.handle) == 0:
             self.current_type_id = TYPE_CODE_MAP.get("SLE4428", 0x04)
             return {"success": True, "type": "SLE4428", "method": "IC_Check_4428"}

        return {"success": False, "message": "Could not identify card"}

    def init_type(self, card_name):
        if self.handle <= 0: return False
        
        type_code = TYPE_CODE_MAP.get(card_name)
        if type_code is None:
            return True 

        self.dll.IC_InitType.argtypes = [ctypes.c_void_p, ctypes.c_short]
        ret = self.dll.IC_InitType(self.handle, type_code)
        
        if ret == 0:
            self.current_type_id = type_code
            return True
        return False

    def read_data(self, offset, length):
        if self.handle <= 0: return None
        
        # IC_Read
        # __int16 IC_Read(HANDLE idComDev,__int16 offset,__int16 len,unsigned char * databuffer)
        self.dll.IC_Read.argtypes = [ctypes.c_void_p, ctypes.c_short, ctypes.c_short, ctypes.POINTER(ctypes.c_ubyte)]
        
        buffer = (ctypes.c_ubyte * length)()
        ret = self.dll.IC_Read(self.handle, offset, length, buffer)
        
        if ret == 0:
            return list(buffer)
        else:
            return None # Error

    def write_data(self, offset, data_list):
        if self.handle <= 0: return -999 # Custom error for not connected
        
        length = len(data_list)
        buffer = (ctypes.c_ubyte * length)(*data_list)
        
        # Dynamic Write Function Selection
        func = self.dll.IC_Write # Default to standard write
        
        # 24C01/02/04/08/16 Series (Code 0x40 / 64)
        if self.current_type_id == 64: 
             func = self.dll.IC_Write24
             
        # 24C64 (Code 0xC0 / 192)
        elif self.current_type_id == 192:
             # Look for IC_Write64, careful if it exists in DLL
             if hasattr(self.dll, 'IC_Write64'):
                 func = self.dll.IC_Write64
             else:
                 pass

        func.argtypes = [ctypes.c_void_p, ctypes.c_short, ctypes.c_short, ctypes.POINTER(ctypes.c_ubyte)]
        ret = func(self.handle, offset, length, buffer)
        
        return ret

    def check_password(self, password_str):
        if self.handle <= 0: return -1
        
        # Determine function based on card type
        # SLE4442 (Code 16 / 0x10)
        # SLE4428 (Code 4 / 0x04)
        
        # According to rDhelp.md, the _hex functions expect hex string like "ffffff"
        # NOT raw bytes. Example from docs:
        #   char Password[7]="ffffff";
        #   st=IC_CheckPass_4442hex(icdev,(unsigned char *)Password);
        
        # Validate hex format
        password_str = password_str.strip().lower()
        if not all(c in '0123456789abcdef' for c in password_str):
            return -2 # Invalid hex format
            
        # Create C-string buffer (null-terminated)
        password_bytes = password_str.encode('ascii') + b'\x00'
        buffer = ctypes.create_string_buffer(password_bytes)
        
        if self.current_type_id == 16: # SLE4442
            # Expected: 6 hex chars = 3 bytes (ffffff)
            func = self.dll.IC_CheckPass_4442hex
            func.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
            func.restype = ctypes.c_int16
            return func(self.handle, buffer)
            
        elif self.current_type_id == 4: # SLE4428
            # Expected: 4 hex chars = 2 bytes (ffff)
            func = self.dll.IC_CheckPass_4428hex
            func.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
            func.restype = ctypes.c_int16
            return func(self.handle, buffer)
            
        return -3 # Not supported for this card type
    
    def read_password_counter(self):
        """Read password counter for 42xx cards. Returns remaining attempts."""
        if self.handle <= 0: return -1
        
        if self.current_type_id == 16: # SLE4442
            func = self.dll.IC_ReadCount_SLE4442
            func.argtypes = [ctypes.c_void_p]
            func.restype = ctypes.c_int16
            return func(self.handle)
            
        elif self.current_type_id == 4: # SLE4428
            func = self.dll.IC_ReadCount_SLE4428
            func.argtypes = [ctypes.c_void_p]
            func.restype = ctypes.c_int16
            return func(self.handle)
            
        return -3 # Not supported
    
    def change_password(self, new_password_str):
        """Change password for 42xx cards. Must verify current password first."""
        if self.handle <= 0: return {"error": -1, "message": "Device not connected"}
        
        # Validate hex format
        new_password_str = new_password_str.strip().lower()
        if not all(c in '0123456789abcdef' for c in new_password_str):
            return {"error": -2, "message": "Invalid hex format"}
        
        # Create C-string buffer (null-terminated)
        password_bytes = new_password_str.encode('ascii') + b'\x00'
        buffer = ctypes.create_string_buffer(password_bytes)
        
        if self.current_type_id == 16: # SLE4442
            # Expected: 6 hex chars = 3 bytes (e.g. "ffffff")
            if len(new_password_str) != 6:
                return {"error": -4, "message": "SLE4442 password must be 6 hex chars (3 bytes)"}
            
            func = self.dll.IC_ChangePass_4442hex
            func.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
            func.restype = ctypes.c_int16
            ret = func(self.handle, buffer)
            
            if ret == 0:
                # Read back password for verification log
                pw_result = self.read_password()
                return {"success": True, "read_back": pw_result.get("password", "Unknown")}
            return {"error": ret, "message": f"ChangePass failed (Code: {ret})"}
            
        elif self.current_type_id == 4: # SLE4428
            # Expected: 4 hex chars = 2 bytes (e.g. "ffff")
            if len(new_password_str) != 4:
                return {"error": -4, "message": "SLE4428 password must be 4 hex chars (2 bytes)"}
            
            func = self.dll.IC_ChangePass_4428hex
            func.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
            func.restype = ctypes.c_int16
            ret = func(self.handle, buffer)
            
            if ret == 0 or ret > 0:  # Doc says >0 is also success for 4428
                pw_result = self.read_password()
                return {"success": True, "read_back": pw_result.get("password", "Unknown")}
            return {"error": ret, "message": f"ChangePass failed (Code: {ret})"}
            
        return {"error": -3, "message": "Card type does not support password change"}
    
    def read_password(self):
        """Read actual password from 42xx cards. Returns hex string or error code."""
        if self.handle <= 0: return {"error": -1}
        
        if self.current_type_id == 16: # SLE4442
            # Try IC_ReadPass_4442hex - it should return 6 hex chars as string
            # Allocate buffer for hex string (6 chars + null terminator + extra)
            buffer = ctypes.create_string_buffer(32)
            func = self.dll.IC_ReadPass_4442hex
            func.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
            func.restype = ctypes.c_int16
            ret = func(self.handle, buffer)
            
            raw_bytes = buffer.raw[:16]
            print(f"[DEBUG] IC_ReadPass_4442hex returned: {ret}, raw: {list(raw_bytes)}")
            
            if ret == 0:
                # Try to decode as ASCII hex string
                try:
                    result = buffer.value.decode('ascii').upper()
                    print(f"[DEBUG] Decoded string: '{result}'")
                    return {"password": result if result else "UNKNOWN"}
                except:
                    # If decode fails, try raw bytes interpretation
                    hex_str = ''.join(f'{b:02X}' for b in raw_bytes if b != 0)
                    return {"password": hex_str}
            return {"error": ret}
            
        elif self.current_type_id == 4: # SLE4428
            # SLE4428 password is 2 bytes
            try:
                buffer = (ctypes.c_ubyte * 2)()
                # Try IC_ReadPass_SLE4428 if it exists
                func = self.dll.IC_ReadPass_SLE4428
                func.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_ubyte)]
                func.restype = ctypes.c_int16
                ret = func(self.handle, buffer)
                if ret == 0:
                    hex_str = ''.join(f'{b:02X}' for b in buffer)
                    return {"password": hex_str}
                return {"error": ret}
            except:
                return {"error": -3, "message": "ReadPass not supported for 4428"}
            
        return {"error": -3}

# Singleton instance management if needed
_driver = None
def get_driver():
    global _driver
    if _driver is None:
        # Determine DLL Path
        if getattr(sys, 'frozen', False):
            # If running as compiled EXE, look in _MEIPASS or same dir
            base_path = sys._MEIPASS
            # Check if dll is bundled in root or a subdir
            dll_path = os.path.join(base_path, "dculc.dll")
            if not os.path.exists(dll_path):
                 # Fallback to checking executable directory
                 dll_path = os.path.join(os.path.dirname(sys.executable), "dculc.dll")
        else:
            # Running as script
            # Assume dll is in a known relative path or hardcoded for dev
            # Dev Path: e:\BACKUP_MSATA\DCULC\Windows.dll\dculc.dll
            # Let's try to find it efficiently or keep using hardcoded for strict dev
            # But for portability, we should probably look in a 'dll' folder or similar.
            # Keeping hardcoded for DEV environment stability as requested, but adding local check.
            dev_path = r"e:\BACKUP_MSATA\DCULC\Windows.dll\dculc.dll"
            if os.path.exists(dev_path):
                dll_path = dev_path
            else:
                 # Fallback for other dev machines -> look in local directory
                 dll_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dculc.dll")

        _driver = DCULCDriver(dll_path)
    return _driver
