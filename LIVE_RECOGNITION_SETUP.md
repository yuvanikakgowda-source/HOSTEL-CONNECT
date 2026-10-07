# Live Recognition Setup

The active implementation is the OpenCV webcam service documented in `FACE_RECOGNITION_README.md`.

Start the main API:

```bash
cd backend
npm install
node server.js
```

Start the Python recognizer:

```bash
cd backend/face_service
pip install -r requirements.txt
cd ..
python face_recognition_service.py
```

Use Flutter's `Face Recognition Attendance` page:

- `Register Face` enrolls the logged-in student from the backend webcam.
- `Start Face Scan` recognizes a live webcam face and marks attendance as `Present`.
- Unknown or duplicate scans do not create attendance records.
