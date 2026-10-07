import os
import time
from typing import Dict, List

import cv2
import face_recognition
import numpy as np

from .database import get_student, save_face_encoding

CAMERA_ACCESS_MESSAGE = (
    'Camera permission denied or camera not available. '
    'Please enable camera access for this device and try again.'
)


class FaceRegistrationError(Exception):
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


def _detect_face_locations(rgb_frame):
    face_locations = face_recognition.face_locations(rgb_frame, model='hog')
    if len(face_locations) == 0:
        face_locations = face_recognition.face_locations(rgb_frame, model='cnn')
    return face_locations


def _encode_single_face(frame, scale: float = 0.5) -> List[float]:
    small_frame = cv2.resize(frame, (0, 0), fx=scale, fy=scale)
    rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
    face_locations = _detect_face_locations(rgb_small_frame)

    if len(face_locations) == 0:
        raise FaceRegistrationError('No face detected')
    if len(face_locations) > 1:
        raise FaceRegistrationError('Multiple faces detected')

    encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
    if len(encodings) == 0:
        raise FaceRegistrationError('Unable to extract face encoding')

    return encodings[0].tolist()


def register_face(
    student_id: int,
    camera_index: int = 0,
    sample_count: int = 5,
    timeout_seconds: int = 30,
    show_window: bool = True,
) -> Dict:
    student = get_student(student_id)
    if student is None:
        raise FaceRegistrationError('Student not found')

    capture = _open_camera(camera_index)
    if not capture.isOpened():
        capture.release()
        raise FaceRegistrationError(CAMERA_ACCESS_MESSAGE)

    encodings = []
    started_at = time.time()
    last_error = 'No face detected'
    window_name = 'HostelConnect Face Registration'

    try:
        while time.time() - started_at < timeout_seconds and len(encodings) < sample_count:
            ok, frame = capture.read()
            if not ok:
                last_error = 'Camera frame could not be read'
                time.sleep(0.1)
                continue

            try:
                encoding = _encode_single_face(frame)
                encodings.append(encoding)
                last_error = ''
                status = f'Captured sample {len(encodings)}/{sample_count}'
                color = (0, 180, 0)
            except FaceRegistrationError as exc:
                last_error = str(exc)
                status = last_error
                color = (0, 0, 255) if last_error != 'Multiple faces detected' else (0, 165, 255)

            if show_window:
                cv2.putText(frame, status, (20, 36), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2)
                cv2.imshow(window_name, frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    raise FaceRegistrationError('Face registration cancelled')

            time.sleep(0.25)
    finally:
        capture.release()
        if show_window:
            try:
                cv2.destroyWindow(window_name)
            except cv2.error:
                pass

    if len(encodings) == 0:
        raise FaceRegistrationError(last_error or 'No face detected')

    averaged_encoding = np.mean(np.array(encodings), axis=0).tolist()
    save_face_encoding(student_id, averaged_encoding)

    return {
        'student_id': student_id,
        'name': student['username'],
        'room_number': student['room_number'],
        'hostel_register_number': student['hostel_register_number'],
        'samples_captured': len(encodings),
        'message': 'Face registered successfully',
    }
