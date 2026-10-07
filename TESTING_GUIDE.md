# Testing & Deployment Guide

## 🚀 Step-by-Step Testing Guide

### Phase 1: Backend Setup (5 minutes)

#### Step 1.1: Install Backend Dependencies
```bash
cd backend
npm install
```
✅ Should complete without errors
✅ Creates `node_modules/` directory

#### Step 1.2: Start Server
```bash
node server.js
```
✅ Output should show: `Server running on port 5001`
✅ Output should show: `Database initialized successfully`
✅ Output should show: `SQLite database created at ./database/hostelconnect.db`

#### Step 1.3: Verify Backend Running
```bash
# In another terminal
curl http://localhost:5001/
```
Expected: Connection accepted (or 404 is OK, means server running)

---

### Phase 2: Frontend Setup (5 minutes)

#### Step 2.1: Install Flutter Dependencies
```bash
cd frontend
flutter pub get
```
✅ Should complete without errors
✅ All packages should resolve successfully

#### Step 2.2: Check Flutter Environment
```bash
flutter doctor
```
Expected output:
- Flutter SDK: ✅
- Android toolchain: ✅ (for Android testing)
- Xcode: ✅ (for iOS testing)
- VS Code / IDE: ✅

#### Step 2.3: List Available Devices
```bash
flutter devices
```
Should see:
- Physical devices connected, OR
- Android emulator, OR
- iOS simulator

---

### Phase 3: Registration Testing (10 minutes)

#### Test Case 3.1: Register Student (Complete Flow)
```bash
flutter run -d <device_id>
```

**Steps**:
1. App opens on device
2. Tap "Student Register" button
3. Enter:
   - Username: `testuser1`
   - Email: `test@hostel.com`
   - Register Number: `HOS001`
   - Password: `Test@123`
4. Tap "Register" button
5. **Camera screen appears** ✅
6. Take a clear selfie (face centered, good lighting)
7. Confirm photo (should see captured image)
8. Tap "Confirm & Register"

**Expected Result**:
- ✅ Registration successful
- ✅ Redirected to login screen
- ✅ Face data stored in database

**Verify in Backend**:
```bash
sqlite3 backend/database/hostelconnect.db
> SELECT id, username, email FROM students;
# Should see: testuser1 | test@hostel.com
> SELECT id, student_id, LENGTH(face_data) as face_length FROM students WHERE id = 1;
# Should see face_data stored (non-zero length)
```

#### Test Case 3.2: Register Second Student
Repeat with:
- Username: `testuser2`
- Email: `test2@hostel.com`
- Register Number: `HOS002`
- Different face

**Purpose**: Verify multiple students with different faces

---

### Phase 4: Login Testing (5 minutes)

#### Test Case 4.1: Login with Correct Credentials
1. App shows login screen
2. Enter:
   - Username: `testuser1`
   - Password: `Test@123`
3. Tap "Login"

**Expected Result**:
- ✅ Login successful
- ✅ Token received
- ✅ Redirected to student dashboard
- ✅ User name displayed

**Verify in Console**:
```
I/Flutter (pid): Login successful for: testuser1
I/Flutter (pid): Token: eyJhbGciOiJIUzI1NiIs...
```

#### Test Case 4.2: Login with Wrong Password
1. Enter correct username, wrong password
2. Tap "Login"

**Expected Result**:
- ✅ Error shown: "Invalid credentials"
- ✅ Stays on login screen
- ✅ Can retry

#### Test Case 4.3: Login Non-Existent User
1. Enter random username
2. Tap "Login"

**Expected Result**:
- ✅ Error shown: "Invalid credentials" or "User not found"
- ✅ Stays on login screen

---

### Phase 5: Attendance Marking Testing (15 minutes)

#### IMPORTANT PREREQUISITES
- **Location**: Must be within 500m of hostel (13.423190°N, 77.146814°E)
- **Time**: Must be within attendance window:
  - Morning: 7:30 AM - 9:00 AM, OR
  - Evening: 6:30 PM - 8:00 PM

#### Test Case 5.1: Mark Attendance (Happy Path)
**Setup**: 
- Device location enabled and within hostel
- Current time within attendance window
- Logged in as `testuser1`

**Steps**:
1. From dashboard, tap "Mark Attendance"
2. **Camera opens automatically** ✅ (front-facing)
3. Status shows "Detecting face..."
4. Position your face in center of screen
5. Wait for face detection (blue bounding box appears)
6. Status shows "Face detected! Processing..."
7. System processes face
8. Status shows "Attendance marked successfully!" ✅
9. Shows confidence score (e.g., "78.5%")
10. Auto-redirects to dashboard after 2 seconds

**Expected Result**:
- ✅ Attendance recorded
- ✅ Confidence score shown
- ✅ Date/time captured
- ✅ Redirected to dashboard

**Verify in Database**:
```bash
sqlite3 backend/database/hostelconnect.db
> SELECT * FROM attendance WHERE student_id = 1;
# Should see: date, time_marked, status, location, confidence
```

**Verify in Backend Logs**:
```
Face similarity: 0.78 (78%)
Attendance marked for student: testuser1
Date: 2025-05-26, Time: 08:45:32
```

#### Test Case 5.2: Multiple Students Mark Attendance
1. Switch to `testuser2` (login with different account)
2. Mark attendance
3. Different face should be recognized

**Expected**:
- ✅ Second student's attendance recorded
- ✅ Different confidence score
- ✅ Both records in database

#### Test Case 5.3: Duplicate Attendance Prevention
1. `testuser1` marks attendance (already marked)
2. Try to mark again

**Expected Result**:
- ✅ Error: "Already marked attendance today"
- ✅ No duplicate record created

**Verify**:
```bash
> SELECT COUNT(*) FROM attendance WHERE student_id = 1 AND date = '2025-05-26';
# Should be 1 (only one record)
```

---

### Phase 6: Edge Cases & Error Handling (20 minutes)

#### Test Case 6.1: Outside Geofence
1. Go to location OUTSIDE 500m radius of hostel
2. Try to mark attendance

**Expected Result**:
- ✅ Error: "You are out of the hostel area"
- ✅ Attendance not marked
- ✅ Location error clear in UI

#### Test Case 6.2: Outside Time Window
1. Try marking attendance at:
   - 9:15 AM (between morning and evening)
   - OR 10:00 PM (after evening window)
2. Try to mark attendance

**Expected Result**:
- ✅ Error: "Out Of Time To Mark Attendance"
- ✅ Attendance not marked
- ✅ Shows correct window times

#### Test Case 6.3: Camera Permission Denied
1. Deny camera permission when prompted
2. Try to mark attendance

**Expected Result**:
- ✅ Error: "Camera permission denied"
- ✅ Option to grant permission
- ✅ Can retry after granting

#### Test Case 6.4: Location Permission Denied
1. Deny location permission when prompted
2. Try to mark attendance

**Expected Result**:
- ✅ Error: "Location permission denied"
- ✅ Option to grant permission
- ✅ Can retry after granting

#### Test Case 6.5: Low Face Similarity (Spoofing Protection)
1. Register with clear face
2. Try marking with different person's face
3. OR try with blurry/angled face

**Expected Result**:
- ✅ Low similarity score (< 40%)
- ✅ Error: "Face not recognized"
- ✅ Shows score: "Similarity: 28%"
- ✅ Can retry

#### Test Case 6.6: No Face Detected
1. Open attendance page
2. Point camera away from face
3. Wait for timeout

**Expected Result**:
- ✅ Status stays "Detecting face..."
- ✅ No false positives
- ✅ Can point face to camera again

---

### Phase 7: Database Verification (5 minutes)

#### Check Students Table
```bash
sqlite3 backend/database/hostelconnect.db
> .mode column
> .headers on
> SELECT id, username, email, LENGTH(face_data) as face_size FROM students;
```

Expected:
```
id|username|email|face_size
1|testuser1|test@hostel.com|4521
2|testuser2|test2@hostel.com|4892
```

#### Check Attendance Records
```bash
> SELECT * FROM attendance;
# Or formatted:
> SELECT 
    id,
    student_id,
    date,
    time_marked,
    status,
    confidence
  FROM attendance
  ORDER BY created_at DESC;
```

Expected:
```
id|student_id|date|time_marked|status|confidence
1|1|2025-05-26|08:45:32|ATTENDANCE MARKED|78.5%
2|2|2025-05-26|08:46:15|ATTENDANCE MARKED|82.3%
```

#### Check Total Records
```bash
> SELECT COUNT(*) as total_students FROM students;
> SELECT COUNT(*) as total_attendance FROM attendance;
> SELECT COUNT(DISTINCT student_id) as unique_students_marked FROM attendance;
```

---

### Phase 8: Performance Testing (10 minutes)

#### Measure Startup Time
```bash
# Clear logs
adb logcat -c  # Android

# Start app
flutter run -d <device_id>

# In logs, find: "Attendance page loaded"
# Measure from app start to that message
# Target: < 5 seconds
```

#### Measure Attendance Marking Time
1. Open attendance page
2. Position face
3. Time from face detection to success message
4. **Target: < 5 seconds total**

#### Monitor Resource Usage
```bash
adb shell "top -n 1 | grep flutter"  # Android CPU/Memory

# Look for:
# - CPU: < 30%
# - Memory: < 100MB
```

#### Monitor Network Traffic
1. Attendance request should be single API call
2. Response should be < 500ms
3. No repeated requests

---

### Phase 9: Multi-Day Testing (Optional)

#### Test Case 9.1: Next Day Attendance
1. Wait until next day (or simulate time change)
2. Mark attendance again
3. Should allow (different date)

**Expected**:
- ✅ New attendance record created
- ✅ Different date in database
- ✅ Allowed to mark again

#### Test Case 9.2: Database Persistence
1. Stop server
2. Restart server
3. Check attendance records still exist

**Expected**:
- ✅ Records persist (database not deleted on restart after first run)
- ✅ Can view historical attendance
- ✅ New registrations still work

---

## 📋 Test Results Template

Use this template to document test results:

```
TEST SESSION: 2025-05-26 08:00 AM
TESTER: [Your Name]
DEVICE: [Device Model + OS Version]
BUILD: [Flutter Version]

═══════════════════════════════════════════════════

TEST CASE 1: Register Student
Status: PASS / FAIL / SKIP
Time: [Seconds]
Issues: [List any problems]

TEST CASE 2: Login Student
Status: PASS / FAIL / SKIP
Time: [Seconds]
Issues: [List any problems]

TEST CASE 3: Mark Attendance (Happy Path)
Status: PASS / FAIL / SKIP
Time: [Seconds]
Confidence Score: [X.X%]
Issues: [List any problems]

TEST CASE 4: Duplicate Prevention
Status: PASS / FAIL / SKIP
Time: [Seconds]
Issues: [List any problems]

TEST CASE 5: Outside Geofence
Status: PASS / FAIL / SKIP
Issues: [List any problems]

TEST CASE 6: Outside Time Window
Status: PASS / FAIL / SKIP
Issues: [List any problems]

TEST CASE 7: Permission Handling
Status: PASS / FAIL / SKIP
Issues: [List any problems]

TEST CASE 8: Low Similarity Detection
Status: PASS / FAIL / SKIP
Similarity Score: [X.X%]
Issues: [List any problems]

═══════════════════════════════════════════════════

OVERALL: PASS / FAIL / PARTIAL
CRITICAL ISSUES: [None] / [List any blocking issues]
RECOMMENDATIONS: [Improvements or next steps]

SIGNED: _________________ DATE: _________
```

---

## 🔧 Troubleshooting During Testing

### App Crashes on Launch
```bash
# Check for errors
flutter run -v -d <device_id>

# Look for:
# - Missing dependencies
# - Permission errors
# - Camera initialization failures
```

### Backend Connection Failed
```bash
# Verify backend running
lsof -i :5001  # Check port 5001 in use

# Or
curl http://localhost:5001/

# Or check backend logs for errors
```

### Face Not Detected
- [ ] Check lighting (sufficient light on face)
- [ ] Check camera lens is clean
- [ ] Check face is centered in frame
- [ ] Check ML Kit is initialized (check logs)
- [ ] Try different angles

### Low Similarity Scores on Valid Face
- [ ] Re-register student with clearer image
- [ ] Adjust threshold in backend (change 0.4 to 0.35)
- [ ] Improve lighting conditions during both registration and marking

### Permissions Not Requesting
- [ ] Uninstall and reinstall app
- [ ] Check manifest/plist files
- [ ] Check Android/iOS OS versions
- [ ] Restart device

### Database Errors
```bash
# Reset database
cd backend
rm -f database/hostelconnect.db  # or del on Windows
node server.js  # Recreates fresh DB
```

---

## ✅ Sign-Off Checklist

### Backend
- [ ] Server starts without errors
- [ ] Database creates successfully
- [ ] API endpoints respond

### Frontend
- [ ] App launches without crashes
- [ ] All screens load
- [ ] Navigation works

### Authentication
- [ ] Student registration works
- [ ] Face capture works
- [ ] Login works

### Attendance
- [ ] Camera auto-opens
- [ ] Face detection works
- [ ] Attendance marks successfully
- [ ] Confidence score displays

### Security
- [ ] Geofence check works
- [ ] Time window check works
- [ ] Duplicate prevention works
- [ ] Photo spoofing prevented

### Data
- [ ] Records stored in database
- [ ] Multiple students supported
- [ ] Historical data persists

---

## 📞 Next Steps After Testing

### If All Tests PASS ✅
1. Deploy to production
2. Monitor server logs
3. Collect confidence scores
4. Gather user feedback
5. Plan enhancements

### If Tests FAIL ❌
1. Check troubleshooting section above
2. Review console logs
3. Check database state
4. Verify backend running
5. Try with different device

### Known Limitations
- Face similarity based on pixel-level Euclidean distance
- No advanced anti-spoofing (eye blink detection)
- Single face per student
- 40% threshold may need tuning

---

**Ready to test?** Start the backend and run the frontend! 🚀
