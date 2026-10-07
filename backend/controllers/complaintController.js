// backend/controllers/complaintController.js
const db = require('../config/database');

// File a complaint (Student)
const fileComplaint = (req, res) => {
  try {
    const studentId = req.user.userId;
    const { complaint_text } = req.body;

    if (!complaint_text || complaint_text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Complaint text is required'
      });
    }

    const today = new Date().toISOString().split('T')[0];

    db.run(
      `INSERT INTO complaints (student_id, complaint_text, status, date_filed)
       VALUES (?, ?, 'Processing', ?)`,
      [studentId, complaint_text, today],
      function (err) {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error filing complaint'
          });
        }

        res.status(201).json({
          success: true,
          message: 'Complaint filed successfully',
          data: {
            id: this.lastID,
            student_id: studentId,
            complaint_text,
            status: 'Processing',
            date_filed: today
          }
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

// Get student complaints
const getStudentComplaints = (req, res) => {
  try {
    const studentId = req.user.userId;

    db.all(
      `SELECT * FROM complaints 
       WHERE student_id = ? 
       ORDER BY date_filed DESC`,
      [studentId],
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching complaints'
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

// Update complaint (Student)
const updateComplaint = (req, res) => {
  try {
    const studentId = req.user.userId;
    const { complaintId } = req.params;
    const { complaint_text } = req.body;

    if (!complaint_text || complaint_text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Complaint text is required'
      });
    }

    // Verify ownership
    db.get(
      'SELECT id FROM complaints WHERE id = ? AND student_id = ?',
      [complaintId, studentId],
      (err, complaint) => {
        if (!complaint) {
          return res.status(403).json({
            success: false,
            message: 'You can only edit your own complaints'
          });
        }

        db.run(
          `UPDATE complaints 
           SET complaint_text = ?, updated_at = CURRENT_TIMESTAMP 
           WHERE id = ?`,
          [complaint_text, complaintId],
          (err) => {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error updating complaint'
              });
            }

            res.json({
              success: true,
              message: 'Complaint updated successfully'
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

// Delete complaint (Student)
const deleteComplaint = (req, res) => {
  try {
    const studentId = req.user.userId;
    const { complaintId } = req.params;

    // Verify ownership
    db.get(
      'SELECT id FROM complaints WHERE id = ? AND student_id = ?',
      [complaintId, studentId],
      (err, complaint) => {
        if (!complaint) {
          return res.status(403).json({
            success: false,
            message: 'You can only delete your own complaints'
          });
        }

        db.run(
          'DELETE FROM complaints WHERE id = ?',
          [complaintId],
          (err) => {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error deleting complaint'
              });
            }

            res.json({
              success: true,
              message: 'Complaint deleted successfully'
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

// Get all complaints (Warden)
const getAllComplaints = (req, res) => {
  try {
    db.all(
      `SELECT c.*, s.username, s.hostel_register_number 
       FROM complaints c
       JOIN students s ON c.student_id = s.id
       ORDER BY c.date_filed DESC`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching complaints'
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

// Update complaint status (Warden)
const updateComplaintStatus = (req, res) => {
  try {
    const { complaintId } = req.params;
    const { status } = req.body;

    if (!['Processing', 'Solved'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    db.run(
      `UPDATE complaints 
       SET status = ?, updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [status, complaintId],
      (err) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error updating complaint'
          });
        }

        res.json({
          success: true,
          message: 'Complaint status updated successfully'
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
  fileComplaint,
  getStudentComplaints,
  updateComplaint,
  deleteComplaint,
  getAllComplaints,
  updateComplaintStatus
};
