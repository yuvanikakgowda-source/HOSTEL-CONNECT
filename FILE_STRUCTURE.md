# 📂 File Structure & Quick Links

## Complete File Map - Live Face Recognition Attendance System

---

## 📁 Project Root
```
hostel_connect/
├── 📄 DOCUMENTATION_INDEX.md ← START HERE
├── 📄 QUICK_START.md
├── 📄 IMPLEMENTATION_SUMMARY.md
├── 📄 IMPLEMENTATION_VERIFICATION.md
├── 📄 FACE_RECOGNITION_README.md
├── 📄 TESTING_GUIDE.md
├── 📄 FILE_STRUCTURE.md ← YOU ARE HERE
│
├── backend/                    # Node.js backend
│   ├── package.json
│   ├── server.js
│   ├── config/
│   │   └── database.js         # ✅ MODIFIED: DB reset logic
│   ├── controllers/
│   │   ├── authController.js   # ✅ MODIFIED: Biometric removed
│   │   ├── attendanceController.js # ✅ MODIFIED: Face verification
│   │   └── ... (other controllers)
│   ├── database/
│   │   └── hostelconnect.db    # SQLite (created fresh on start)
│   └── ...
│
└── frontend/                   # Flutter frontend
    ├── pubspec.yaml            # ✅ MODIFIED: Dependencies updated
    ├── lib/
    │   ├── main.dart
    │   ├── services/
    │   │   ├── face_detection_service.dart  # ✅ NEW: Face detection
    │   │   ├── api_service.dart
    │   │   └── ...
    │   ├── screens/
    │   │   ├── auth/
    │   │   │   ├── student_login_screen.dart    # Updated
    │   │   │   ├── student_register_screen.dart # Updated
    │   │   │   └── ...
    │   │   └── student/
    │   │       ├── attendance_screen.dart (legacy)
    │   │       ├── attendance_face_screen.dart  # ✅ NEW: Main attendance
    │   │       └── ...
    │   ├── routes/
    │   │   └── app_router.dart # ✅ MODIFIED: Route updated
    │   ├── providers/
    │   ├── models/
    │   ├── widgets/
    │   ├── utils/
    │   └── core/
    │       └── constants/
    │           └── app_constants.dart # ✅ MODIFIED: Biometric keys removed
    ├── android/
    │   └── app/src/main/
    │       └── AndroidManifest.xml # ✅ MODIFIED: Permissions added
    ├── ios/
    │   └── Runner/
    │       └── Info.plist           # ✅ MODIFIED: Permissions added
    └── ...
```

---

## 🔴 CRITICAL FILES (Must Understand These)

### Frontend - Attendance & Face Recognition
1. **[attendance_face_screen.dart](frontend/lib/screens/student/attendance_face_screen.dart)**
   - Main attendance UI with live camera
   - ~380 lines
   - Contains: Camera initialization, face detection, status display
   - Key method: `_processCameraFrames()`

2. **[face_detection_service.dart](frontend/lib/services/face_detection_service.dart)**
   - Face detection and embedding extraction
   - ~180 lines
   - Contains: ML Kit integration, image format conversion
   - Key method: `detectFaces()`, `getFaceEmbedding()`, `calculateSimilarity()`

### Backend - Face Verification
3. **[attendanceController.js](backend/controllers/attendanceController.js)**
   - Attendance marking with face verification
   - Contains: `markAttendance()`, `calculateFaceSimilarity()`
   - Key logic: Similarity threshold check (0.4 = 40%)

### Database
4. **[database.js](backend/config/database.js)**
   - Database initialization and schema
   - Resets on server startup
   - Schema: students (with face_data), attendance

---

## 🟡 IMPORTANT FILES (Understand These)

### Authentication
- [authController.js](backend/controllers/authController.js)
  - Student/Warden registration and login
  - Modified: Biometric removed, face_data added for students

- [student_login_screen.dart](frontend/lib/screens/auth/student_login_screen.dart)
  - Username/password login
  - Modified: Biometric logic removed

- [student_register_screen.dart](frontend/lib/screens/auth/student_register_screen.dart)
  - Student registration with face capture
  - Modified: Uses image_picker for camera capture

### Configuration
- [pubspec.yaml](frontend/pubspec.yaml)
  - Dependencies: camera, google_mlkit_face_detection, image
  - Removed: local_auth

- [app_router.dart](frontend/lib/routes/app_router.dart)
  - Route definitions
  - `/student-attendance` → AttendanceFaceScreen()

- [app_constants.dart](frontend/lib/core/constants/app_constants.dart)
  - Attendance times, geofence location
  - Removed: Biometric storage keys

### Permissions
- [AndroidManifest.xml](frontend/android/app/src/main/AndroidManifest.xml)
  - CAMERA, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION

- [Info.plist](frontend/ios/Runner/Info.plist)
  - NSCameraUsageDescription
  - NSLocationWhenInUseUsageDescription

---

## 🟢 REFERENCE FILES (Good to Know)

### State Management
- [attendance_provider.dart](frontend/lib/providers/attendance_provider.dart)
  - Attendance state management with Riverpod

- [auth_provider.dart](frontend/lib/providers/auth_provider.dart)
  - Authentication state management
  - Modified: Biometric parameters removed

### API & HTTP
- [api_service.dart](frontend/lib/services/api_service.dart)
  - HTTP client (Dio)
  - Methods for API calls

### Models
- [student_model.dart](frontend/lib/models/)
  - Student data structure

- [attendance_model.dart](frontend/lib/models/)
  - Attendance data structure

### Routes
- [authRoutes.js](backend/routes/authRoutes.js)
  - POST /auth/register/student
  - POST /auth/login/student

- [attendanceRoutes.js](backend/routes/attendanceRoutes.js)
  - POST /attendance/mark
  - GET /attendance/status

---

## 📊 Key Implementation Details

### Face Similarity Algorithm
**Location**: [attendanceController.js](backend/controllers/attendanceController.js)
**Function**: `calculateFaceSimilarity(face1, face2)`
**Algorithm**: Euclidean distance
**Formula**: `similarity = 1 - (distance / 1000)`
**Threshold**: 0.4 (40%)

```javascript
function calculateFaceSimilarity(face1, face2) {
  // Converts base64 to Buffer
  // Calculates Euclidean distance between pixel values
  // Returns 0-1 where 1 = perfect match
  // Used for: Face verification
}
```

### Face Detection
**Location**: [face_detection_service.dart](frontend/lib/services/face_detection_service.dart)
**Method**: `detectFaces(CameraImage)`
**Library**: Google ML Kit
**Returns**: List of Face objects with bounding boxes

```dart
Future<List<Face>> detectFaces(CameraImage image) {
  // Processes camera frame
  // Detects faces in real-time
  // Returns list of Face objects
}
```

### Real-Time Processing
**Location**: [attendance_face_screen.dart](frontend/lib/screens/student/attendance_face_screen.dart)
**Method**: `_processCameraFrames()`
**Flow**: 
1. Start image stream from camera
2. For each frame: detect faces
3. On detection: extract embedding
4. Send to backend
5. Get similarity score
6. If > 40%: mark attendance

---

## 🔗 Cross-File Dependencies

### Frontend Flow
```
attendance_face_screen.dart
    ↓
    ├→ face_detection_service.dart (ML Kit face detection)
    ├→ attendance_provider.dart (Riverpod state)
    ├→ api_service.dart (HTTP requests)
    └→ app_constants.dart (Geofence, times, API URL)
```

### Backend Flow
```
attendanceRoutes.js
    ↓
    attendanceController.js (markAttendance)
    ↓
    ├→ database.js (Query student face_data)
    ├→ calculateFaceSimilarity() (0.4 threshold)
    ├→ Response with confidence
    └→ Create attendance record
```

### Database Flow
```
database.js (initialization)
    ↓
    ├→ students table (id, username, face_data)
    ├→ attendance table (id, student_id, date, time, status, confidence)
    └→ Reset on server startup (delete .db, recreate)
```

---

## 🎯 File Modification Checklist

### ✅ Files Modified (7 total)
- [x] backend/config/database.js
- [x] backend/controllers/authController.js
- [x] backend/controllers/attendanceController.js
- [x] frontend/pubspec.yaml
- [x] frontend/lib/routes/app_router.dart
- [x] frontend/android/app/src/main/AndroidManifest.xml
- [x] frontend/ios/Runner/Info.plist

### ✅ Files Created (2 total)
- [x] frontend/lib/services/face_detection_service.dart
- [x] frontend/lib/screens/student/attendance_face_screen.dart

### ✅ Documentation Created (6 total)
- [x] DOCUMENTATION_INDEX.md
- [x] QUICK_START.md
- [x] IMPLEMENTATION_SUMMARY.md
- [x] IMPLEMENTATION_VERIFICATION.md
- [x] FACE_RECOGNITION_README.md
- [x] TESTING_GUIDE.md
- [x] FILE_STRUCTURE.md (this file)

---

## 📱 Code Line Counts

| File | Lines | Type | Status |
|---|---|---|---|
| face_detection_service.dart | 180 | Service | ✅ NEW |
| attendance_face_screen.dart | 380 | Screen | ✅ NEW |
| attendanceController.js | ~200 | Backend | ✅ MODIFIED |
| authController.js | ~150 | Backend | ✅ MODIFIED |
| database.js | ~80 | Config | ✅ MODIFIED |
| app_router.dart | ~100 | Route | ✅ MODIFIED |
| student_login_screen.dart | ~150 | Screen | ✅ MODIFIED |
| student_register_screen.dart | ~200 | Screen | ✅ MODIFIED |

---

## 🔍 How to Find Specific Features

### Find Face Detection Logic
1. Open: [face_detection_service.dart](frontend/lib/services/face_detection_service.dart)
2. Search: `detectFaces`
3. ~Line: 45-65

### Find Face Similarity Calculation
1. Open: [attendanceController.js](backend/controllers/attendanceController.js)
2. Search: `calculateFaceSimilarity`
3. ~Line: 213-240

### Find Attendance Endpoint
1. Open: [attendanceController.js](backend/controllers/attendanceController.js)
2. Search: `markAttendance`
3. ~Line: 30-110

### Find Live Camera Preview
1. Open: [attendance_face_screen.dart](frontend/lib/screens/student/attendance_face_screen.dart)
2. Search: `_processCameraFrames`
3. ~Line: 75-140

### Find Permissions Declaration
1. Android: [AndroidManifest.xml](frontend/android/app/src/main/AndroidManifest.xml)
2. iOS: [Info.plist](frontend/ios/Runner/Info.plist)

### Find Geofence Constants
1. Open: [app_constants.dart](frontend/lib/core/constants/app_constants.dart)
2. Search: `HOSTEL_LATITUDE` or `HOSTEL_LONGITUDE`
3. ~Line: (varies)

### Find API Configuration
1. Open: [app_constants.dart](frontend/lib/core/constants/app_constants.dart)
2. Search: `API_URL` or `BASE_URL`
3. Backend URL: http://localhost:5001

---

## 🚀 Quick Edit Guide

### To Change Similarity Threshold
1. File: [attendanceController.js](backend/controllers/attendanceController.js)
2. Find: `const THRESHOLD = 0.4;`
3. Change: `0.4` to desired value (0-1)
4. Restart: `node server.js`

### To Change Geofence Location
1. File: [app_constants.dart](frontend/lib/core/constants/app_constants.dart)
2. Find: `HOSTEL_LATITUDE`, `HOSTEL_LONGITUDE`, `GEOFENCE_RADIUS`
3. Update: New coordinates and radius
4. Rebuild: `flutter run`

### To Change Attendance Time Windows
1. File: [app_constants.dart](frontend/lib/core/constants/app_constants.dart)
2. Find: `MORNING_START_TIME`, `MORNING_END_TIME`, etc.
3. Update: New times
4. Rebuild: `flutter run`

### To Change Camera Resolution
1. File: [attendance_face_screen.dart](frontend/lib/screens/student/attendance_face_screen.dart)
2. Find: `ResolutionPreset.medium`
3. Change: To `low`, `medium`, `high`, or `veryHigh`
4. Rebuild: `flutter run`

### To Change Face Detection Model
1. File: [face_detection_service.dart](frontend/lib/services/face_detection_service.dart)
2. Find: `FaceDetector` initialization
3. Update: ML Kit options if needed
4. Rebuild: `flutter run`

---

## 📋 Deployment Checklist

### Backend Deployment
- [ ] Update database.js if needed (fresh schema)
- [ ] Update attendanceController.js threshold if needed
- [ ] Run: `npm install`
- [ ] Run: `node server.js`
- [ ] Verify: API accessible at localhost:5001

### Frontend Deployment
- [ ] Update app_constants.dart (API URL, geofence, times)
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run -d <device>`
- [ ] Test: All scenarios in TESTING_GUIDE.md

### Database Deployment
- [ ] Ensure fresh SQLite creation
- [ ] Verify schema has face_data column
- [ ] Check no fingerprint columns

### Permissions Deployment
- [ ] Android: Verify AndroidManifest.xml changes
- [ ] iOS: Verify Info.plist changes
- [ ] Test: Request permissions on both platforms

---

## 🐛 Debug Quick Links

### Backend Debugging
- Similarity calculation: [attendanceController.js](backend/controllers/attendanceController.js) line ~220
- Database queries: [database.js](backend/config/database.js) line ~30
- API responses: [attendanceRoutes.js](backend/routes/attendanceRoutes.js)

### Frontend Debugging
- Face detection: [face_detection_service.dart](frontend/lib/services/face_detection_service.dart) line ~45
- Camera initialization: [attendance_face_screen.dart](frontend/lib/screens/student/attendance_face_screen.dart) line ~36
- API calls: [api_service.dart](frontend/lib/services/api_service.dart)

### Common Issues
- See: [TESTING_GUIDE.md](TESTING_GUIDE.md) → Troubleshooting
- See: [QUICK_START.md](QUICK_START.md) → Troubleshooting

---

## 📞 Quick Reference

| Need | Location | Type |
|---|---|---|
| Setup instructions | QUICK_START.md | Doc |
| Technical details | FACE_RECOGNITION_README.md | Doc |
| API documentation | FACE_RECOGNITION_README.md | Doc |
| Test procedures | TESTING_GUIDE.md | Doc |
| Face detection code | face_detection_service.dart | Code |
| Attendance UI | attendance_face_screen.dart | Code |
| Backend verification | attendanceController.js | Code |
| Permissions | AndroidManifest.xml, Info.plist | Config |
| Constants | app_constants.dart | Config |
| Dependencies | pubspec.yaml | Config |

---

## ✨ Summary

**All files are organized and documented!**

### Start Here
1. Read: DOCUMENTATION_INDEX.md (overview)
2. Read: QUICK_START.md (setup)
3. Reference: This file (navigation)

### Key Files
- Frontend: attendance_face_screen.dart, face_detection_service.dart
- Backend: attendanceController.js, database.js
- Config: app_constants.dart, AndroidManifest.xml, Info.plist

### For More Info
- See: DOCUMENTATION_INDEX.md → How to Use This Documentation
- See: QUICK_START.md → Quick Setup
- See: FACE_RECOGNITION_README.md → Technical Deep Dive

---

**Everything is ready for deployment!** 🚀
