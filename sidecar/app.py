from flask import Flask, request, jsonify, send_file, make_response
from werkzeug.utils import secure_filename
from tusclient import client
import requests
import os

app = Flask(__name__)

TUS_SERVER_URL = os.getenv('TUS_SERVER_URL', '')


@app.route('/files/', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    filename = secure_filename(file.filename)
    tus_client = client.TusClient(f"http://{TUS_SERVER_URL}:1080/files/")

    uploader = tus_client.uploader(file_stream=file.stream, metadata={'filename': filename})
    uploader.upload()

    return jsonify({'fileId': uploader.url.rsplit('/', 1)[-1]}), 201


@app.route('/files/<path:path>', methods=['GET'])
def download_file(path):
    if request.method == 'OPTIONS':
        return make_response()

    try:
        response = requests.get(f"http://{TUS_SERVER_URL}:1080/files/" + path, stream=True)
        response.raise_for_status()
        return send_file(response.raw, as_attachment=True)
    except requests.HTTPError as e:
        return jsonify({'error': 'Failed to download file: ' + str(e)}), e.response.status_code


@app.route('/files/<path:path>', methods=['DELETE', 'OPTIONS'])
def delete_file(path):
    if request.method == 'OPTIONS':
        return make_response()

    try:
        response = requests.delete(f"http://{TUS_SERVER_URL}:1080/files/" + path)
        response.raise_for_status()
        return make_response('', 204)
    except requests.HTTPError as e:
        return jsonify({'error': 'Failed to delete file: ' + str(e)}), e.response.status_code
    

if __name__ == '__main__':
    app.run(debug=True)
