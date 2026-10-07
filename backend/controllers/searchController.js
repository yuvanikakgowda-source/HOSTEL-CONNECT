// backend/controllers/searchController.js
const db = require('../config/database');

// Search students by username or register number
const searchStudents = (req, res) => {
  try {
    const { query } = req.query;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters'
      });
    }

    const searchTerm = `%${query}%`;

    db.all(
      `SELECT s.id, s.username, s.hostel_register_number, s.email, s.phone, s.created_at,
              r.floor, r.room_number, r.room_type, r.capacity,
              r.room_id AS roomId
       FROM students s
       LEFT JOIN room_allocations ra ON ra.student_id = s.id AND ra.status = 'Active'
       LEFT JOIN rooms r ON r.id = ra.room_id
       WHERE s.username LIKE ? OR s.hostel_register_number LIKE ?
       ORDER BY s.username`,
      [searchTerm, searchTerm],
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error searching students'
          });
        }

        res.json({
          success: true,
          data: rows,
          count: rows.length
        });
      }
    );
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

// Get student by ID with all details
const getStudentDetails = (req, res) => {
  try {
    const { studentId } = req.params;

    db.get(
      `SELECT id, username, hostel_register_number, email, phone, created_at
       FROM students
       WHERE id = ? OR hostel_register_number = ?`,
      [studentId, studentId],
      (err, student) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching student'
          });
        }
        if (!student) {
          return res.status(404).json({
            success: false,
            message: 'Student not found'
          });
        }

        db.all(
          `SELECT ah.id, ah.attendance_id, ah.user_id AS userId, ah.student_name AS studentName,
                  ah.status, ah.year, ah.month, ah.day, ah.date, ah.time, ah.timestamp
           FROM attendance_history ah
           WHERE ah.student_id = ?
           ORDER BY ah.timestamp DESC`,
          [student.id],
          (attendanceErr, attendance) => {
            if (attendanceErr) {
              return res.status(500).json({ success: false, message: 'Error fetching attendance history' });
            }

            db.get(
              `SELECT r.room_id AS roomId, r.floor, r.room_type, r.room_number, r.capacity,
                      COUNT(occ.id) AS occupied,
                      GROUP_CONCAT(os.username || '|' || os.hostel_register_number) AS occupants_csv
               FROM room_allocations ra
               JOIN rooms r ON r.id = ra.room_id
               LEFT JOIN room_allocations occ ON occ.room_id = r.id AND occ.status = 'Active'
               LEFT JOIN students os ON os.id = occ.student_id
               WHERE ra.student_id = ? AND ra.status = 'Active'
               GROUP BY r.id
               LIMIT 1`,
              [student.id],
              (roomErr, room) => {
                if (roomErr) {
                  return res.status(500).json({ success: false, message: 'Error fetching room allocation' });
                }

                const roomAllocation = room
                  ? {
                      roomId: room.roomId,
                      floor: room.floor,
                      room_type: room.room_type,
                      room_number: room.room_number,
                      capacity: room.capacity,
                      occupied: room.occupied,
                      occupants: room.occupants_csv
                        ? room.occupants_csv.split(',').filter(Boolean).map((item) => {
                            const [username, userId] = item.split('|');
                            return { username, hostel_register_number: userId };
                          })
                        : [],
                    }
                  : null;

                res.json({
                  success: true,
                  data: {
                    student: {
                      ...student,
                      userId: student.hostel_register_number,
                      room_allocation: roomAllocation,
                    },
                    attendance,
                    attendanceHistory: attendance,
                    roomAllocation,
                  }
                });
              }
            );
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

module.exports = {
  searchStudents,
  getStudentDetails
};
