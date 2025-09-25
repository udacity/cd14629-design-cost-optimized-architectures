from flask import Flask, render_template, request, jsonify
import psutil
import requests
import threading
import time
import multiprocessing

app = Flask(__name__)

# Global variables for CPU load control
load_threads = []
stop_loading = threading.Event()

def get_ec2_metadata():
    """Get EC2 instance metadata using IMDSv2"""
    try:
        # Get session token for IMDSv2
        token_url = "http://169.254.169.254/latest/api/token"
        token_headers = {"X-aws-ec2-metadata-token-ttl-seconds": "21600"}
        token_response = requests.put(token_url, headers=token_headers, timeout=2)
        token = token_response.text
        
        # Use token to get metadata
        metadata_url = "http://169.254.169.254/latest/meta-data/"
        headers = {"X-aws-ec2-metadata-token": token}
        
        instance_id = requests.get(f"{metadata_url}instance-id", headers=headers, timeout=2).text
        instance_type = requests.get(f"{metadata_url}instance-type", headers=headers, timeout=2).text
        availability_zone = requests.get(f"{metadata_url}placement/availability-zone", headers=headers, timeout=2).text
        
        try:
            public_ip = requests.get(f"{metadata_url}public-ipv4", headers=headers, timeout=2).text
        except:
            public_ip = "Not assigned"
            
        private_ip = requests.get(f"{metadata_url}local-ipv4", headers=headers, timeout=2).text
        
        return {
            'instance_id': instance_id,
            'instance_type': instance_type,
            'availability_zone': availability_zone,
            'public_ip': public_ip,
            'private_ip': private_ip
        }
    except Exception as e:
        return {
            'instance_id': 'Not available (not on EC2)',
            'instance_type': 'Not available',
            'availability_zone': 'Not available',
            'public_ip': 'Not available',
            'private_ip': 'Not available'
        }

def cpu_load_worker(target_percent):
    """Worker function to generate CPU load"""
    while not stop_loading.is_set():
        start_time = time.time()
        # Busy loop for the target percentage of time
        while time.time() - start_time < target_percent / 100.0:
            pass
        # Sleep for the remaining time
        time.sleep(max(0, 1 - (target_percent / 100.0)))

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/instance-info')
def instance_info():
    """API endpoint to get EC2 instance information"""
    metadata = get_ec2_metadata()
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    return jsonify({
        'metadata': metadata,
        'cpu_percent': cpu_percent,
        'memory_percent': memory.percent,
        'memory_total': round(memory.total / (1024**3), 2),  # GB
        'memory_used': round(memory.used / (1024**3), 2)     # GB
    })

@app.route('/api/start-load', methods=['POST'])
def start_load():
    """Start CPU load generation"""
    global load_threads, stop_loading
    
    # Stop any existing load
    stop_loading.set()
    for thread in load_threads:
        thread.join()
    
    # Get target CPU percentage
    target_percent = int(request.json.get('percent', 0))
    
    if target_percent > 0:
        stop_loading.clear()
        load_threads = []
        
        # Create one thread per CPU core
        num_cores = multiprocessing.cpu_count()
        for _ in range(num_cores):
            thread = threading.Thread(target=cpu_load_worker, args=(target_percent,))
            thread.daemon = True
            thread.start()
            load_threads.append(thread)
    
    return jsonify({'status': 'success', 'target_percent': target_percent})

@app.route('/api/stop-load', methods=['POST'])
def stop_load():
    """Stop CPU load generation"""
    global stop_loading
    stop_loading.set()
    return jsonify({'status': 'stopped'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)