import os
import time
from typing import Dict, List, Optional, Tuple

import cv2
import face_recognition
import numpy as np

from .attendance_service import DuplicateAttendanceError, mark_attendance
from .database import load_registered_faces

CAMERA_ACCESS_MESSAGE = (
    'Camera permission denied or camera not available. '
    'Please enable camera access for this device and try again.'
)


class FaceRecognitionError(Exception):
    pass


def _open_camera(camera_index: int) -> cv2.VideoCapture:
    def open_with_backend(backend):
        capture = cv2.VideoCapture(camera_index, backend)
        capture.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        capture.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
        return capture

    if os.name == 'nt':
        for backend in (cv2.CAP_DSHOW, cv2.CAP_MSMF, cv2.CAP_ANY):
            capture = open_with_backend(backend)
            if capture.isOpened():
                return capture
            capture.release()

    return open_with_backend(cv2.CAP_ANY)


def _match_face(
    face_encoding: List[float],
    known_encodings: List[List[float]],
    tolerance: float,
) -> Tuple[Optional[int], Optional[float]]:
    if len(known_encodings) == 0:
        return None, None

    distances = face_recognition.face_distance(np.array(known_encodings), face_encoding)
    best_index = int(np.argmin(distances))
    best_distance = float(distances[best_index])
    if best_distance <= tolerance:
        return best_index, best_distance
    return None, best_distance


def _detect_face_locations(rgb_frame):
    face_locations = face_recognition.face_locations(rgb_frame, model='hog')
    if len(face_locations) == 0:
        face_locations = face_recognition.face_locations(rgb_frame, model='cnn')
    return face_locations


def _draw_status(frame, text: str, color) -> None:
    cv2.rectangle(frame, (0, 0), (frame.shape[1], 54), (25, 25, 25), -1)
    cv2.putText(frame, text, (18, 36), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2)


def start_webcam_scan(
    camera_index: int = 0,
    timeout_seconds: int = 30,
    capture_interval: float = 0.2,
    tolerance: float = 0.6,
    show_window: bool = True,
) -> Dict:
    registered_faces = load_registered_faces()
    if len(registered_faces) == 0:
        return {
            'success': False,
            'recognized': False,
            'reason': 'no_registered_faces',
            'message': 'No registered faces available',
        }

    known_encodings = [face['encoding'] for face in registered_faces]
    capture = _open_camera(camera_index)
    if not capture.isOpened():
        capture.release()
        raise FaceRecognitionError(CAMERA_ACCESS_MESSAGE)

    started_at = time.time()
    last_processed_at = 0.0
    last_result = {
        'success': False,
        'recognized': False,
        'reason': 'no_face',
        'message': 'No face detected',
    }
    window_name = 'HostelConnect Attendance Scanner'

    try:
        while time.time() - started_at < timeout_seconds:
            ok, frame = capture.read()
            if not ok:
                last_result = {
                    'success': False,
                    'recognized': False,
                    'reason': 'camera_frame_error',
                    'message': 'Camera frame could not be read',
                }
                time.sleep(0.1)
                continue

            should_process = time.time() - last_processed_at >= capture_interval
            if should_process:
                last_processed_at = time.time()
                small_frame = cv2.resize(frame, (0, 0), fx=0.5, fy=0.5)
                rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
                face_locations = _detect_face_locations(rgb_small_frame)

                if len(face_locations) == 0:
                    last_result = {
                        'success': False,
                        'recognized': False,
                        'reason': 'no_face',
                        'message': 'No face detected',
                    }
                elif len(face_locations) > 1:
                    last_result = {
                        'success': False,
                        'recognized': False,
                        'reason': 'multiple_faces',
                        'message': 'Multiple faces detected',
                    }
                    if show_window:
                        _draw_status(frame, 'Multiple faces detected', (0, 165, 255))
                        cv2.imshow(window_name, frame)
                        cv2.waitKey(600)
                    return last_result
                else:
                    encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
                    if len(encodings) == 0:
                        last_result = {
                            'success': False,
                            'recognized': False,
                            'reason': 'no_encoding',
                            'message': 'Unable to extract face encoding',
                        }
                    else:
                        match_index, distance = _match_face(encodings[0], known_encodings, tolerance)
                        if match_index is None:
                            last_result = {
                                'success': True,
                                'recognized': False,
                                'reason': 'unknown',
                                'message': 'Unknown Person',
                                'distance': distance,
                            }
                        else:
                            student = registered_faces[match_index]
                            try:
                                attendance = mark_attendance(student['id'])
                                return {
                                    'success': True,
                                    'recognized': True,
                                    'student_id': student['id'],
                                    'username': student['name'],
                                    'hostel_register_number': student['hostel_register_number'],
                                    'room_number': student['room_number'],
                                    'distance': distance,
                                    'message': 'Attendance marked successfully',
                                    'attendance': attendance,
                                }
                            except DuplicateAttendanceError as exc:
                                return {
                                    'success': False,
                                    'recognized': True,
                                    'student_id': student['id'],
                                    'username': student['name'],
                                    'hostel_register_number': student['hostel_register_number'],
                                    'room_number': student['room_number'],
                                    'distance': distance,
                                    'message': str(exc),
                                    'attendance': None,
                                }

            if show_window:
                status = last_result.get('message', 'Scanning...')
                if last_result.get('recognized') is True:
                    color = (0, 180, 0)
                elif last_result.get('reason') == 'unknown':
                    color = (0, 0, 255)
                else:
                    color = (0, 165, 255)
                _draw_status(frame, status, color)
                cv2.imshow(window_name, frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    raise FaceRecognitionError('Attendance scan cancelled')
    finally:
        capture.release()
        if show_window:
            try:
                cv2.destroyWindow(window_name)
            except cv2.error:
                pass

    if last_result.get('reason') == 'unknown':
        return last_result

    return {
        'success': False,
        'recognized': False,
        'reason': 'timeout',
        'message': last_result.get('message') or 'No face detected during scan',
    }
