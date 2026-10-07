# HostelConnect OpenCV Face Recognition Attendance

HostelConnect now uses a Python OpenCV service for live webcam-based face enrollment and attendance marking. Flutter does not upload attendance images, does not calculate face embeddings, and cannot mark attendance directly. Attendance is inserted only after the Python service recognizes a registered face.

## Architecture

- `backend/face_recognition_service.py` starts the Flask recognition service on port `6000`.
- `backend/face_service/database.py` connects to `backend/database/hostelconnect.db` and stores encodings in `students.face_encoding`.
- `backend/face_service/face_registration.py` opens the backend webcam, captures one registered student at a time, averages several `face_recognition` encodings, and saves the result.
- `backend/face_service/face_recognition.py` opens the backend webcam, detects one face in real time, compares it with registered encodings, displays `Unknown Person` for unmatched faces, and marks attendance for matched students.
- `backend/face_service/attendance_service.py` inserts `Present` attendance with date/time and relies on `UNIQUE(student_id, date)` to prevent duplicate daily entries.
- `backend/routes/faceRecognitionRoutes.js` proxies authenticated Flutter requests to the Python service.

## Database Schema

Fresh databases create:

```sql
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  hostel_register_number TEXT UNIQUE NOT NULL,
  email TEXT,
  phone TEXT,
  room_number TEXT,
  floor INTEGER,
  face_encoding TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  date DATE NOT NULL,
  day TEXT,
  time_marked TIME,
  status TEXT DEFAULT 'Absent',
  latitude REAL,
  longitude REAL,
  is_morning INTEGER DEFAULT 0,
  is_evening INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE(student_id, date)
);
```

For existing databases, the Python service adds `students.face_encoding` if it is missing.

## API Endpoints

Through the Node backend:

```http
POST /api/face/register-face
Authorization: Bearer <student token>
Body: {}
```

Opens the backend webcam and enrolls the authenticated student.

```http
POST /api/face/start-scan
Authorization: Bearer <student token>
Body: {}
```

Starts live webcam scanning. If a registered face matches, attendance is marked immediately. If no match is found, the API returns `Unknown Person` and no attendance row is inserted.

```http
GET /api/face/attendance-records?student_id=<id>&date=YYYY-MM-DD
Authorization: Bearer <token>
```

Returns attendance records from the shared HostelConnect database.

Existing read endpoints remain available:

```http
GET /api/attendance/my-attendance
GET /api/attendance/all
GET /api/attendance/student/:studentId
GET /api/attendance/statistics
```

`POST /api/attendance/mark` has been removed so attendance cannot bypass face recognition.

## Setup

Install Node dependencies:

```bash
cd backend
npm install
node server.js
```

Install Python dependencies:

```bash
cd backend/face_service
pip install -r requirements.txt
cd ..
python face_recognition_service.py
```

Run Flutter:

```bash
cd frontend
flutter pub get
flutter run
```

## Flutter Flow

1. Student registers with username, password, register number, and email.
2. Student opens `Face Recognition Attendance`.
3. Student taps `Register Face` once to enroll through the backend webcam.
4. Student taps `Start Face Scan`.
5. The Python service recognizes the face and inserts `Present`.
6. Flutter refreshes `attendanceProvider`, so the updated attendance record is visible immediately.

## Error Handling

- Camera unavailable: returns `503` with `Camera not available`.
- No face detected: returns `No face detected`; no attendance row is inserted.
- Multiple faces detected: returns `Multiple faces detected`; no attendance row is inserted.
- Unknown face: displays and returns `Unknown Person`; no attendance row is inserted.
- Duplicate attendance: returns `Attendance already marked today`.
- Database connection/schema errors: return `500` with the database error message.
