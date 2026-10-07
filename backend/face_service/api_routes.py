from flask import Flask, jsonify, request

from .database import DatabaseError, ensure_schema, fetch_attendance_records
from .face_recognition import FaceRecognitionError, start_webcam_scan
from .face_registration import FaceRegistrationError, register_face


def _bool_payload_value(payload, key: str, default: bool) -> bool:
    value = payload.get(key, default)
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.lower() in {'1', 'true', 'yes', 'on'}
    return bool(value)


def create_app() -> Flask:
    app = Flask(__name__)
    ensure_schema()

    @app.route('/api/health', methods=['GET'])
    def health_check():
        return jsonify({'success': True, 'message': 'Face recognition service is running'})

    @app.route('/api/register-face', methods=['POST'])
    def register_face_route():
        payload = request.get_json(silent=True) or {}
        student_id = payload.get('student_id')
        if not student_id:
            return jsonify({'success': False, 'message': 'student_id is required'}), 400

        try:
            result = register_face(
                student_id=int(student_id),
                camera_index=int(payload.get('camera_index', 0)),
                sample_count=int(payload.get('sample_count', 5)),
                timeout_seconds=int(payload.get('timeout_seconds', 30)),
                show_window=_bool_payload_value(payload, 'show_window', True),
            )
            return jsonify({'success': True, 'data': result, 'message': result['message']})
        except FaceRegistrationError as exc:
            message = str(exc)
            status = 403 if 'Camera permission denied' in message else 400
            return jsonify({'success': False, 'message': message}), status
        except DatabaseError as exc:
            return jsonify({'success': False, 'message': str(exc)}), 500
        except Exception as exc:
            return jsonify({'success': False, 'message': f'Registration failed: {exc}'}), 500

    @app.route('/api/start-scan', methods=['POST'])
    def start_scan_route():
        payload = request.get_json(silent=True) or {}
        try:
            result = start_webcam_scan(
                camera_index=int(payload.get('camera_index', 0)),
                timeout_seconds=int(payload.get('timeout_seconds', 30)),
                capture_interval=float(payload.get('capture_interval', 0.2)),
                tolerance=float(payload.get('tolerance', 0.55)),
                show_window=_bool_payload_value(payload, 'show_window', True),
            )
            return jsonify(result)
        except FaceRecognitionError as exc:
            message = str(exc)
            status = 403 if 'Camera permission denied' in message else 400
            return jsonify({'success': False, 'recognized': False, 'message': message}), status
        except DatabaseError as exc:
            return jsonify({'success': False, 'recognized': False, 'message': str(exc)}), 500
        except Exception as exc:
            return jsonify({'success': False, 'recognized': False, 'message': f'Scan failed: {exc}'}), 500

    @app.route('/api/attendance-records', methods=['GET'])
    def attendance_records_route():
        student_id = request.args.get('student_id', type=int)
        attendance_date = request.args.get('date')
        try:
            records = fetch_attendance_records(student_id=student_id, attendance_date=attendance_date)
            return jsonify({'success': True, 'data': records})
        except DatabaseError as exc:
            return jsonify({'success': False, 'message': str(exc)}), 500
        except Exception as exc:
            return jsonify({'success': False, 'message': f'Unable to fetch attendance records: {exc}'}), 500

    return app
