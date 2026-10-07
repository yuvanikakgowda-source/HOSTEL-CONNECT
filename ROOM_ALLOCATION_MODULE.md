# Room Allocation Module - Implementation Guide

## 📋 Overview

The **Room Allocation Module** is a comprehensive solution for managing student room assignments in the Hostel Management System. It allows Wardens to efficiently allocate, update, and manage student room assignments while ensuring data consistency across the system.

---

## 🎯 Features Implemented

### Warden Dashboard Features
✅ **Comprehensive Room Table View**
- Display floor number, room number, room type, capacity
- Show current occupancy status (Occupied/Vacant)
- View all students in each room
- Filter rooms by floor
- Filter rooms by status (Occupied/Vacant)
- Search rooms by room number

✅ **Room Management Operations**
- Create new rooms with floor, room number, capacity, and type
- Allocate students to rooms with validation
- Remove/reassign students from rooms
- Prevent duplicate allocations
- Check room capacity before allocation

✅ **Student Management**
- Search for unallocated students
- View detailed student information
- Allocate multiple students to shared rooms
- Track allocation history

### Student Dashboard Features
✅ **Room Information Display**
- View assigned room details (floor, room number)
- See list of roommates
- Display room occupancy status
- View room guidelines and rules
- Handle unallocated status gracefully

---

## 🗄️ Database Schema

### Tables Created/Modified

#### 1. **rooms**
```sql
CREATE TABLE rooms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  floor INTEGER NOT NULL,
  room_number TEXT NOT NULL,
  room_type TEXT DEFAULT 'Double',
  capacity INTEGER NOT NULL,
  current_occupancy INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(floor, room_number)
)
```

#### 2. **room_allocations** (New)
```sql
CREATE TABLE room_allocations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  room_id INTEGER NOT NULL,
  floor INTEGER NOT NULL,
  room_number TEXT NOT NULL,
  allocation_date DATE DEFAULT CURRENT_DATE,
  status TEXT DEFAULT 'Active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  UNIQUE(student_id, room_id)
)
```

#### 3. **students** (Modified)
- Added fields: `room_number`, `floor` (already existed)
- Fields are updated when room allocation changes

---

## 🔌 Backend API Endpoints

### Room Management Endpoints

#### 1. **Get All Rooms**
```
GET /api/rooms/all
Auth: Required (Warden)
Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "floor": 1,
      "room_number": "101",
      "capacity": 2,
      "current_occupancy": 1,
      "students": ["john_doe"],
      "student_count": 1
    }
  ]
}
```

#### 2. **Get Detailed Room Information**
```
GET /api/rooms/detailed
Auth: Required (Warden)
Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "floor": 1,
      "room_number": "101",
      "room_type": "Double",
      "capacity": 2,
      "current_occupancy": 1,
      "status": "Occupied",
      "students": [
        {
          "id": 5,
          "username": "john_doe",
          "hostel_register_number": "2023001",
          "email": "john@example.com",
          "phone": "1234567890"
        }
      ]
    }
  ]
}
```

#### 3. **Get Unallocated Students**
```
GET /api/rooms/unallocated
Auth: Required (Warden)
Response:
{
  "success": true,
  "data": [
    {
      "id": 10,
      "username": "jane_doe",
      "hostel_register_number": "2023002",
      "email": "jane@example.com",
      "phone": "0987654321"
    }
  ]
}
```

#### 4. **Filter Rooms by Floor**
```
GET /api/rooms/filter/floor?floor=1
Auth: Required (Warden)
Response: Filtered room list by floor number
```

#### 5. **Filter Rooms by Status**
```
GET /api/rooms/filter/status?status=Occupied
Auth: Required (Warden)
Params: status = 'Occupied' | 'Vacant'
Response: Filtered room list by occupancy status
```

#### 6. **Search Rooms**
```
GET /api/rooms/search?query=101
Auth: Required (Warden)
Response: Rooms matching the search query
```

#### 7. **Create Room**
```
POST /api/rooms/create
Auth: Required (Warden)
Body:
{
  "floor": 1,
  "room_number": "101",
  "capacity": 2,
  "room_type": "Double"
}
Response:
{
  "success": true,
  "message": "Room created successfully",
  "data": {
    "id": 1,
    "floor": 1,
    "room_number": "101",
    "capacity": 2
  }
}
```

#### 8. **Allocate Student to Room**
```
PUT /api/rooms/allocate/:studentId
Auth: Required (Warden)
Body:
{
  "room_id": 1,
  "floor": 1,
  "room_number": "101"
}
Response:
{
  "success": true,
  "message": "Room allocation updated successfully"
}
```

#### 9. **Remove Student from Room**
```
PUT /api/rooms/remove/:studentId
Auth: Required (Warden)
Response:
{
  "success": true,
  "message": "Student removed from room"
}
```

#### 10. **Get Student's Room**
```
GET /api/rooms/my-room
Auth: Required (Student)
Response:
{
  "success": true,
  "data": {
    "room_number": "101",
    "floor": 1,
    "students": [
      { "id": 5, "username": "john_doe" },
      { "id": 6, "username": "jane_doe" }
    ],
    "student_count": 2
  }
}
```

---

## 🎨 Frontend Implementation

### Warden Room Allocation Screen
**File:** `frontend/lib/screens/warden/room_allocation_screen.dart`

**Features:**
- Data table showing all rooms with complete information
- Horizontal scroll for better table view
- Search functionality for room numbers
- Floor and status filters
- Inline action buttons for allocate/remove
- Create new room dialog
- Allocate student dialog with search
- Student removal with confirmation

**Key Components:**
```dart
RoomAllocationScreen
├── Search Bar (room number)
├── Filter Bar (floor, status)
├── DataTable
│   ├── Room Details (Floor, Number, Type, Capacity)
│   ├── Occupancy Info
│   └── Action Buttons
├── AllocateStudentDialog
└── FloatingActionButton (Create Room)
```

### Student Room Info Screen
**File:** `frontend/lib/screens/student/room_info_screen.dart`

**Features:**
- Beautiful gradient room header card
- Room statistics (roommates, total occupants)
- List of roommates with avatars
- Room guidelines and rules
- Handle unallocated status
- Real-time updates via polling

**Key Widgets:**
```dart
RoomInfoScreen
├── Room Header Card (Floor, Room Number)
├── Statistics Cards (Roommates, Occupants)
├── Roommates List
└── Room Guidelines
```

### Models
**File:** `frontend/lib/models/room_model.dart`

```dart
class StudentInfo {
  final int id;
  final String username;
  final String? hostelRegisterNumber;
  final String? email;
  final String? phone;
}

class RoomModel {
  final int id;
  final int floor;
  final String roomNumber;
  final String roomType;
  final int capacity;
  final int currentOccupancy;
  final List<String> students;
  final List<StudentInfo> studentDetails;
  final String status; // 'Occupied' / 'Vacant'
}
```

---

## 🔄 Data Flow & Integration

### Room Allocation Flow
```
Warden Dashboard
       ↓
[Search/Filter Rooms]
       ↓
[Click Allocate Button]
       ↓
[Search Student Dialog]
       ↓
[Select Student]
       ↓
PUT /api/rooms/allocate/:studentId
       ↓
Update Database (students table + room_allocations)
       ↓
Update Room Occupancy
       ↓
Refresh UI & Show Success Message
       ↓
Student's Room Info Auto-Updates (via polling)
```

### Real-Time Sync
- **Student Room Info:** Uses `StudentRoomProvider` with 5-second polling interval
- **Warden Dashboard:** Uses `allRoomsProvider` with refresh on allocation changes
- **Database:** Transactional updates ensure data consistency

---

## 📱 Usage Guide

### For Wardens

#### Step 1: View Room Allocations
1. Navigate to "Room Allocation" from the Warden Dashboard
2. View all rooms in table format
3. Check current occupancy and status

#### Step 2: Create a New Room
1. Click the **"+"** button (FloatingActionButton)
2. Enter room details:
   - Floor Number
   - Room Number
   - Capacity
   - Room Type (Single/Double/Triple)
3. Click "Create"

#### Step 3: Allocate a Student
1. Click **"Person Add"** icon in the Actions column
2. In the dialog, search for a student by username
3. Select the student from the search results
4. Click "Allocate"

#### Step 4: Remove a Student
1. Click the **"More Options"** menu in the Actions column
2. Select "Remove: [StudentName]"
3. Confirm the removal

#### Step 5: Filter Rooms
- **By Floor:** Enter floor number in the filter field
- **By Status:** Select "Occupied" or "Vacant" from dropdown
- **By Search:** Enter room number in the search field

### For Students

#### View Room Information
1. Navigate to "My Room" from the Student Dashboard
2. View your assigned room details
3. See your roommates and contact information
4. Review room guidelines

#### If Not Allocated
1. See "No Room Allocated" message
2. Click "Contact Warden" button
3. Submit a room allocation request

---

## ✅ Validation & Constraints

### Business Logic
- ✅ **Unique Rooms:** No duplicate room/floor combinations
- ✅ **Capacity Check:** Cannot allocate when room is full
- ✅ **Duplicate Prevention:** One student cannot be in multiple rooms simultaneously
- ✅ **Data Consistency:** Student and room records stay synchronized
- ✅ **Transactional Updates:** All-or-nothing updates to prevent partial allocations

### Error Handling
```
Scenarios Handled:
- Room full (max capacity reached)
- Student already allocated
- Student not found
- Invalid room
- Database transaction failures
- Network errors
```

---

## 🔐 Security

### Authentication & Authorization
- All endpoints require authentication
- Warden endpoints require Warden role verification
- Student endpoints require Student role verification
- No cross-student data visibility

### Data Protection
- Foreign key constraints prevent orphaned records
- Transactional operations ensure data integrity
- Soft deletes via status field (for audit trail)

---

## 📊 Database Relationships

```
students (1) ─── (N) room_allocations
              ↓
            rooms
              ↑
        ┌─────┴──────┐
        │             │
    (1 room)    (Multiple students)
```

---

## 🚀 Deployment Checklist

- [ ] Database migrations applied (room_allocations table created)
- [ ] Backend endpoints tested (via Postman/curl)
- [ ] Flutter screens compiled without errors
- [ ] Providers configured correctly
- [ ] API routes registered in router
- [ ] Navigation routes added for new screens
- [ ] Error handling implemented
- [ ] Real-time polling configured (5-second interval)
- [ ] UI responsive on mobile and web
- [ ] Search and filter working correctly

---

## 📝 Future Enhancements

1. **Advanced Filtering**
   - Filter by room type
   - Filter by date range
   - Advanced search with multiple criteria

2. **Batch Operations**
   - Bulk room creation
   - Bulk student allocation
   - CSV import/export

3. **Real-Time Updates**
   - WebSocket instead of polling
   - Push notifications on allocation changes
   - Live room availability updates

4. **Reporting**
   - Room occupancy reports
   - Student allocation history
   - Vacancy analysis

5. **Preferences & Constraints**
   - Student room preferences
   - Room allocation algorithms
   - Compatibility matching for roommates

---

## 🐛 Troubleshooting

### Common Issues

**Issue:** Room not showing in list after creation
**Solution:** Refresh the page or wait for auto-refresh to trigger

**Issue:** Allocation fails with "Room is full"
**Solution:** Check if room capacity is exceeded; allocate to a different room

**Issue:** Student room info not updating
**Solution:** Check if polling interval is active; manually refresh with the Retry button

**Issue:** API returns 401 Unauthorized
**Solution:** Verify authentication token; login again if needed

---

## 📞 Support & Contact

For issues or feature requests related to the Room Allocation Module, contact:
- **Email:** support@hostelconnect.local
- **Issue Tracker:** GitHub Issues
- **Warden Support:** In-app Help Center

---

**Version:** 1.0.0  
**Last Updated:** June 2, 2026  
**Status:** Production Ready
