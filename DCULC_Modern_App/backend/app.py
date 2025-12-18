import os
import sys
import webbrowser
import time
import threading
from threading import Timer
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from driver_wrapper import get_driver

# Determine paths for Static Files (Frontend)
if getattr(sys, 'frozen', False):
    # If frozen with PyInstaller, frontend files should be bundled in 'frontend' dir inside _MEIPASS
    template_folder = os.path.join(sys._MEIPASS, 'frontend')
    static_folder = os.path.join(sys._MEIPASS, 'frontend')
else:
    # If running as script, frontend is sibling to backend
    # Current dir: backend/
    base_dir = os.path.dirname(os.path.abspath(__file__))
    frontend_dir = os.path.join(os.path.dirname(base_dir), 'frontend')
    template_folder = frontend_dir
    static_folder = frontend_dir

app = Flask(__name__, static_folder=static_folder, static_url_path='')
CORS(app) # Enable CORS

# Heartbeat Logic for Auto-Shutdown
last_heartbeat = 0

@app.before_request
def log_request():
    if request.path == '/api/heartbeat':
        print(f"Received Heartbeat: {request.method} {request.path}")

@app.route('/api/heartbeat', methods=['GET', 'POST', 'OPTIONS'])
def heartbeat():
    if request.method == 'OPTIONS':
        return jsonify({"status": "ok"})
        
    global last_heartbeat
    last_heartbeat = time.time()
    return jsonify({"status": "ok"})

def monitor_heartbeat():
    global last_heartbeat
    # Grace period on startup (15s)
    last_heartbeat = time.time() + 15
    while True:
        time.sleep(2)
        # If no heartbeat for 15 seconds, shut down (10s is too risky for network/browser lag)
        if time.time() - last_heartbeat > 15: 
            print(f"Heartbeat lost (Diff: {time.time() - last_heartbeat:.1f}s). Shutting down...")
            os._exit(0)

# IMPORTANT: Start thread BEFORE defining app or other global vars if possible, 
# but here we are in global scope.
monitor_thread = threading.Thread(target=monitor_heartbeat, daemon=True)
monitor_thread.start()

driver = get_driver()

# Ensure all errors are JSON
@app.errorhandler(Exception)
def handle_exception(e):
    import traceback
    traceback.print_exc()
    return jsonify({"status": "error", "message": str(e), "trace": traceback.format_exc()}), 500

@app.errorhandler(500)
def handle_500(e):
    return jsonify({"status": "error", "message": "Internal Server Error"}), 500

@app.errorhandler(404)
def handle_404(e):
    return jsonify({"status": "error", "message": "Endpoint not found (404)"}), 404

@app.errorhandler(405)
def handle_405(e):
    return jsonify({"status": "error", "message": "Method not allowed (405)"}), 405

@app.route('/api/shutdown', methods=['POST'])
def shutdown():
    shutdown_func = request.environ.get('werkzeug.server.shutdown')
    if shutdown_func:
        shutdown_func()
    else:
        # Fallback for when running without Werkzeug (e.g. some prod setups or direct python execution)
        # os._exit(0) is forceful but effective for a standalone app
        Timer(0.5, lambda: os._exit(0)).start() # Delay slightly to allow response to return
    return jsonify({"status": "ok", "message": "Server shutting down..."})

driver = get_driver()

# Serve Index
@app.route('/')
def index():
    return send_from_directory(app.static_folder, 'index.html')

# Serve other static assets if needed explicitly (Flask static_url_path='' handles most)
# But standard Flask static serving usually expects /static prefix. 
# We mapped static_url_path='' so it serves directly from root.

def open_browser():
    webbrowser.open_new('http://127.0.0.1:5000/')

@app.route('/api/connect', methods=['POST'])
def connect():
    try:
        success = driver.connect()
        if success:
            return jsonify({"status": "connected", "message": "Device connected successfully"})
        else:
            return jsonify({"status": "error", "message": "Failed to connect to device. Check connection."}), 500
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/disconnect', methods=['POST'])
def disconnect():
    driver.disconnect()
    return jsonify({"status": "disconnected"})

@app.route('/api/status', methods=['GET'])
def status():
    code = driver.check_status()
    # 0 = Card Present, 1 = No Card, <0 Error
    if code == 0:
        return jsonify({"status": "ok", "card_present": True})
    elif code == 1:
        return jsonify({"status": "ok", "card_present": False})
    else:
        return jsonify({"status": "error", "code": code})

@app.route('/api/detect', methods=['POST'])
def detect():
    result = driver.auto_detect()
    return jsonify(result)

@app.route('/api/set_type', methods=['POST'])
def set_type():
    data = request.json
    card_type = data.get('type')
    if not card_type:
        return jsonify({"status": "error", "message": "Type is required"}), 400
    
    success = driver.init_type(card_type)
    if success:
        return jsonify({"status": "ok", "message": f"Card type set to {card_type}"})
    else:
        return jsonify({"status": "error", "message": "Failed to set card type"}), 500

@app.route('/api/read', methods=['POST'])
def read_card():
    data = request.json
    offset = data.get('offset', 0)
    length = data.get('length', 16)
    
    print(f"Reading: offset={offset}, len={length}")
    
    result = driver.read_data(offset, length)
    if result is not None:
        # result is a list of bytes
        hex_str = ''.join(f'{b:02X} ' for b in result)
        ascii_str = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in result)
        return jsonify({
            "status": "ok",
            "data": result,
            "hex": hex_str,
            "ascii": ascii_str
        })
    else:
        return jsonify({"status": "error", "message": "Read failed"}), 500

@app.route('/api/write', methods=['POST'])
def write_card():
    try:
        data = request.json
        offset = data.get('offset', 0)
        bytes_data = data.get('data', []) # List of ints
        
        ret_code = driver.write_data(offset, bytes_data)
        
        # 0 = Standard Success
        # 257 (0x101) = Also seen as success for some operations based on user feedback
        if ret_code == 0 or ret_code == 257:
            return jsonify({"status": "ok", "message": "Write successful"})
        else:
            return jsonify({"status": "error", "message": f"Write failed (Code: {ret_code})", "code": ret_code}), 500
    except Exception as e:
        import traceback
        traceback.print_exc() # Print to console for dev
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/verify_password', methods=['POST'])
def verify_password():
    data = request.json
    password = data.get('password', '')
    
    ret = driver.check_password(password)
    
    # Only 0 = Success
    if ret == 0:
        # After successful verification, read counter
        # Note: read_password() has DLL bug (3rd byte always 00), so we don't show it
        counter = driver.read_password_counter()
        
        return jsonify({
            'status': 'ok',
            'counter': counter if counter >= 0 else None
        })
    elif ret == -2:
        return jsonify({'status': 'error', 'message': 'Invalid Hex Password'})
    elif ret == -3:
        return jsonify({'status': 'error', 'message': 'Card does not support password'})
    else:
        # Also return counter on failure so user knows remaining attempts
        counter = driver.read_password_counter()
        return jsonify({
            'status': 'error', 
            'message': f'Verification Failed (Code: {ret})',
            'counter': counter if counter >= 0 else None
        })

@app.route('/api/password_counter', methods=['GET'])
def get_password_counter():
    """Get password counter (remaining attempts) for 42xx cards."""
    counter = driver.read_password_counter()
    if counter >= 0:
        return jsonify({'status': 'ok', 'counter': counter})
    else:
        return jsonify({'status': 'error', 'code': counter})

@app.route('/api/read_password', methods=['GET'])
def read_password():
    """Read actual password from 42xx cards."""
    result = driver.read_password()
    if 'password' in result:
        return jsonify({'status': 'ok', 'password': result['password']})
    else:
        return jsonify({'status': 'error', 'code': result.get('error'), 'message': result.get('message', 'Read failed')})

@app.route('/api/change_password', methods=['POST'])
def change_password():
    """Change password for 42xx cards. Requires prior password verification."""
    data = request.json
    new_password = data.get('new_password', '')
    
    if not new_password:
        return jsonify({'status': 'error', 'message': 'New password is required'})
    
    result = driver.change_password(new_password)
    
    if result.get('success'):
        # Log the read-back password to console
        print(f"[PASSWORD CHANGED] IC_ReadPass returned: {result.get('read_back', 'Unknown')}")
        return jsonify({
            'status': 'ok',
            'message': 'Password changed successfully',
            'read_back': result.get('read_back')
        })
    else:
        return jsonify({
            'status': 'error',
            'message': result.get('message', 'Change failed'),
            'code': result.get('error')
        })

if __name__ == '__main__':
    print("Starting DCULC Backend Server on port 5000...")
    
    # Check if running as frozen executable (PyInstaller)
    if getattr(sys, 'frozen', False):
        # Production / EXE Mode - Use waitress for clean output
        from waitress import serve
        print("Using Waitress WSGI Server")
        Timer(1.5, open_browser).start()
        serve(app, host='127.0.0.1', port=5000, threads=4)
    else:
        # Development Mode - Use Flask dev server for hot-reload
        # WERKZEUG_RUN_MAIN is set to 'true' by the reloader child process
        # Only open browser in the parent process to avoid double-open
        if os.environ.get('WERKZEUG_RUN_MAIN') != 'true':
            Timer(1.5, open_browser).start()
        app.run(port=5000, debug=True)
