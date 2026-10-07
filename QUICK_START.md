# Quick Start Guide - Live Face Recognition Attendance

## 🚀 Quick Setup (5 minutes)

### 1. Backend Start
```bash
cd backend
npm install
node server.js
```
✅ Server runs at `http://localhost:5001`
✅ Fresh SQLite database created at `backend/database/hostelconnect.db`

### 2. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d <device>
```

### 3. Test Registration
- **Route**: `/student-register`
- Enter: username, password, register number, email
- **Camera opens**: Capture your face (selfie)
- Face data stored automatically

### 4. Test Login
- **Route**: `/student-login`
- Enter: username & password
- No face required for login

### 5. Test Attendance (NEW)
- **Route**: `/student-attendance`
- Camera **auto-opens** on screen load
- Point face at camera
- System detects face in real-time
- Attendance marked automatically ✅

---

## 📱 Device Requirements

| Requirement | Details |
|---|---|
| **Android** | 5.0+ with camera & location permissions |
| **iOS** | 11+ with camera & location permissions |
| **Camera** | Front-facing camera required |
| **Location** | Must be within hostel geofence (13.423190°N, 77.146814°E, 500m radius) |

---

## ⏰ Attendance Marking Times

- **Morning**: 7:30 AM - 9:00 AM
- **Evening**: 6:30 PM - 8:00 PM

Mark attendance outside these times will show status: "Out Of Time To Mark Attendance"

---

## 🎯 Live Face Recognition Flow

```
1. Student opens attendance page
   ↓
2. Camera initializes (front-facing) 🎥
   ↓
3. ML Kit detects face in real-time 👤
   ↓
4. Location verified (geofence check) 📍
   ↓
5. Time validated (morning/evening) ⏱️
   ↓
6. Face embedding extracted & sent to backend 🔍
   ↓
7. Backend compares with stored face 🔬
   ↓
8. If similarity > 40% → Attendance marked ✅
   ↓
9. Confidence score displayed 📊
   ↓
10. Auto-redirect to dashboard 🏠
```

---

## 📊 Key Features

✅ **Automatic Camera** - Opens on attendance page load
✅ **Real-Time Detection** - ML Kit face detection + tracking
✅ **Live Verification** - Requires live camera feed (no photos)
✅ **Location Check** - Verifies within hostel area
✅ **Time Window** - Only morning/evening times allowed
✅ **Confidence Score** - Shows matching confidence %
✅ **Error Handling** - Clear messages for all failure cases

---

## 🔧 Backend API

### Mark Attendance Endpoint
```
POST /attendance/mark
Content-Type: application/json

{
  "latitude": 13.423190,
  "longitude": 77.146814,
  "status": "ATTENDANCE MARKED",
  "is_morning": 1,
  "is_evening": 0,
  "image_data": "base64-encoded-face-frame"
}

Response:
{
  "success": true,
  "message": "Attendance marked successfully",
  "confidence": "65.3%",
  "data": {
    "id": 1,
    "student_id": 1,
    "date": "2026-05-26",
    "day": "Monday",
    "time_marked": "08:45:32"
  }
}
```

---

## 🐛 Debug Tips

### Check Face Detection
```dart
// In attendance_face_screen.dart
print('Faces detected: ${faces.length}');
print('Face bounds: ${face.boundingBox}');
```

### View Server Logs
```bash
# Terminal where server is running
# Look for: "Face similarity: X.XX"
# Look for: "Attendance marked for student: X"
```

### Database Check
```bash
# List attendance records
sqlite3 backend/database/hostelconnect.db
> SELECT * FROM attendance;
> SELECT * FROM students WHERE id = 1;
```

---

## ❌ Troubleshooting

| Issue | Solution |
|---|---|
| **Camera not opening** | Grant camera permission, restart app |
| **Face not detected** | Better lighting, center face, check ML Kit logs |
| **Low similarity score** | Re-register with clearer face image |
| **Attendance not marking** | Check location (must be in geofence), check time window |
| **"No cameras available"** | Device may not have front camera |

---

## 📦 Updated Dependencies

**Added**:
- `camera: ^0.10.5`
- `google_mlkit_face_detection: ^0.10.0`
- `image: ^4.0.0`

**Removed**:
- `local_auth: ^2.1.0` (biometric auth)

**Run**: `flutter pub get` to install

---

## 🔐 Security Notes

✅ **Live Face Only** - Photos/screenshots rejected
✅ **Stored Face Verification** - New face compared against registered
✅ **Similarity Threshold** - 40% minimum (tunable)
✅ **Location Verification** - GPS geofence check
✅ **Time Window** - Only during allowed times
✅ **One Attendance Per Day** - Prevents duplicate marking

---

## 📝 Files Modified/Created

### New Files
- `frontend/lib/services/face_detection_service.dart` - Face detection logic
- `frontend/lib/screens/student/attendance_face_screen.dart` - New live attendance UI
- `FACE_RECOGNITION_README.md` - Full technical documentation

### Modified Files
- `frontend/pubspec.yaml` - Added camera & ML Kit
- `frontend/lib/routes/app_router.dart` - Updated attendance route
- `backend/config/database.js` - DB reset logic
- `backend/controllers/attendanceController.js` - Face verification
- `android/app/src/main/AndroidManifest.xml` - Permissions
- `ios/Runner/Info.plist` - Privacy descriptions

---

## 🎉 Success Criteria

✅ App starts without errors
✅ Student can register with face capture
✅ Student can login with username/password
✅ Attendance page opens with live camera
✅ Face is detected and recognized in real-time
✅ Attendance marked with confidence score
✅ Multiple students can be registered & recognized

---

## 📞 Next Steps

1. **Tune similarity threshold** if needed (backend: 0.4 = 40%)
2. **Add advanced liveness detection** (eye blink, head movement)
3. **Integrate deep learning models** (FaceNet, ArcFace) for better accuracy
4. **Deploy to production** with proper face recognition backend

---

**Ready to test?** Start the backend, run the frontend, and try marking attendance! 🚀
