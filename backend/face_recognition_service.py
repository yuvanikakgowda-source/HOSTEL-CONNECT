import os

from face_service.api_routes import create_app


if __name__ == '__main__':
    port = int(os.environ.get('RECOGNIZER_PORT', 6000))
    app = create_app()
    app.run(host='0.0.0.0', port=port, debug=False)
