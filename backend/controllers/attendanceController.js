// backend/controllers/attendanceController.js
const db = require('../config/database');

const buildAttendanceWhere = (filters = {}, tableAlias = 'ah') => {
  const clauses = [];
  const params = [];

  if (filters.studentId) {
    clauses.push(`${tableAlias}.student_id = ?`);
    params.push(filters.studentId);
  }
  if (filters.userId) {
    clauses.push(`${tableAlias}.user_id = ?`);
    params.push(filters.userId);
  }
  if (filters.date) {
    clauses.push(`${tableAlias}.date = ?`);
    params.push(filters.date);
  }
  if (filters.month) {
    clauses.push(`${tableAlias}.month = ?`);
    params.push(filters.month);
  }
  if (filters.year) {
    clauses.push(`${tableAlias}.year = ?`);
    params.push(Number(filters.year));
  }

  return {
    where: clauses.length ? `WHERE ${clauses.join(' AND ')}` : '',
    params,
  };
};

const historySelect = `
  SELECT ah.id, ah.attendance_id, ah.student_id, ah.user_id, ah.user_id AS userId,
         ah.student_name, ah.student_name AS studentName, ah.status,
         ah.year, ah.month, ah.day, ah.date, ah.time, ah.timestamp,
         s.username, s.hostel_register_number
  FROM attendance_history ah
  JOIN students s ON s.id = ah.student_id
`;

// Get attendance for a student
const getStudentAttendance = (req, res) => {
  try {
    const studentId = req.user.userId;
    const { where, params } = buildAttendanceWhere({ studentId });

    db.all(
      `${historySelect}
       ${where}
       ORDER BY ah.timestamp DESC`,
      params,
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching attendance'
          });
        }

        res.json({
          success: true,
          data: rows
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

// Get all attendance (Warden)
const getAllAttendance = (req, res) => {
  try {
    const { date, month, year, userId } = req.query;
    const { where, params } = buildAttendanceWhere({ date, month, year, userId });

    db.all(
      `${historySelect}
       ${where}
       ORDER BY ah.timestamp DESC, s.username ASC`,
      params,
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching attendance'
          });
        }

        res.json({
          success: true,
          data: rows
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

// Get attendance by student ID (Warden)
const getAttendanceByStudent = (req, res) => {
  try {
    const { studentId } = req.params;
    const { date, month, year } = req.query;

    db.get(
      `SELECT id FROM students WHERE id = ? OR hostel_register_number = ?`,
      [studentId, studentId],
      (studentErr, student) => {
        if (studentErr) {
          return res.status(500).json({ success: false, message: 'Error fetching student' });
        }
        if (!student) {
          return res.status(404).json({ success: false, message: 'Student not found' });
        }

        const { where, params } = buildAttendanceWhere({
          studentId: student.id,
          date,
          month,
          year,
        });

        db.all(
          `${historySelect}
           ${where}
           ORDER BY ah.timestamp DESC`,
          params,
          (err, rows) => {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error fetching attendance'
              });
            }

            res.json({
              success: true,
              data: rows
            });
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

// Get attendance statistics
const getAttendanceStats = (req, res) => {
  try {
    db.all(
      `SELECT s.id, s.username, s.hostel_register_number,
              COUNT(a.id) as total_days,
              SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) as present,
              SUM(CASE WHEN a.status IS NOT NULL AND a.status != 'Present' THEN 1 ELSE 0 END) as absent
       FROM students s
       LEFT JOIN attendance a ON s.id = a.student_id
       GROUP BY s.id
       ORDER BY s.username`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching statistics'
          });
        }

        res.json({
          success: true,
          data: rows
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

module.exports = {
  getStudentAttendance,
  getAllAttendance,
  getAttendanceByStudent,
  getAttendanceStats
};
