"""
Computer Monitoring Dashboard - Flask Web Application
Serves web dashboard and API endpoints for computer status monitoring
"""

from flask import Flask, render_template, jsonify, send_from_directory, request
import json
import os
import subprocess
from datetime import datetime

app = Flask(__name__)

# Configuration
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, 'data')
CONFIG_FILE = os.path.join(BASE_DIR, 'config.json')
STATUS_FILE = os.path.join(DATA_DIR, 'status.json')
HISTORY_FILE = os.path.join(DATA_DIR, 'history.json')

def load_config():
    """Load configuration from config.json"""
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading config: {e}")
        return None

def load_json_file(file_path):
    """Load and return JSON file contents"""
    try:
        if os.path.exists(file_path):
            with open(file_path, 'r') as f:
                return json.load(f)
        return None
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return None

@app.route('/')
def dashboard():
    """Serve the main dashboard page"""
    config = load_config()
    refresh_interval = config['dashboardSettings']['refreshIntervalSeconds'] if config else 30
    return render_template('dashboard.html', refresh_interval=refresh_interval)

@app.route('/api/status')
def api_status():
    """API endpoint: Return current computer status"""
    data = load_json_file(STATUS_FILE)
    if data:
        return jsonify(data)
    else:
        return jsonify({
            'error': 'Status data not available',
            'message': 'Monitoring script may not have run yet'
        }), 404

@app.route('/api/history')
def api_history():
    """API endpoint: Return state change history"""
    data = load_json_file(HISTORY_FILE)
    if data:
        return jsonify(data)
    else:
        return jsonify({
            'lastUpdate': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'eventCount': 0,
            'events': []
        })

@app.route('/api/config')
def api_config():
    """API endpoint: Return dashboard configuration"""
    config = load_config()
    if config:
        return jsonify({
            'refreshInterval': config['dashboardSettings']['refreshIntervalSeconds'],
            'monitoringInterval': config['monitoringInterval']
        })
    else:
        return jsonify({'error': 'Configuration not available'}), 404

@app.route('/api/restart-rdp', methods=['POST'])
def api_restart_rdp():
    """API endpoint: Restart RDP service on remote computer"""
    try:
        data = request.get_json()
        computer_name = data.get('computerName')
        
        if not computer_name:
            return jsonify({'success': False, 'message': 'Computer name is required'}), 400
        
        # Path to PowerShell script
        script_path = os.path.join(BASE_DIR, 'scripts', 'restart-rdp-remote.ps1')
        
        # Execute PowerShell script
        result = subprocess.run(
            ['pwsh.exe', '-ExecutionPolicy', 'Bypass', '-File', script_path, '-ComputerName', computer_name],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            return jsonify({
                'success': True,
                'message': f'RDP service restart initiated on {computer_name}',
                'output': result.stdout
            })
        else:
            return jsonify({
                'success': False,
                'message': f'Failed to restart RDP service on {computer_name}',
                'error': result.stderr
            }), 500
            
    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'message': 'Operation timed out (60 seconds)'
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # Load configuration
    config = load_config()
    
    if config:
        host = config['dashboardSettings']['host']
        port = config['dashboardSettings']['port']
        
        print("=" * 50)
        print("Computer Monitoring Dashboard")
        print("=" * 50)
        print(f"Starting Flask server on {host}:{port}")
        print(f"Dashboard URL: http://localhost:{port}")
        if host == '0.0.0.0':
            print(f"Network access enabled - accessible from other devices")
        print("Press Ctrl+C to stop")
        print("=" * 50)
        
        app.run(host=host, port=port, debug=False)
    else:
        print("ERROR: Could not load configuration file")
        exit(1)
