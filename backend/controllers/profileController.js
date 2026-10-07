// backend/controllers/profileController.js
const db = require('../config/database');
const { hashPassword, comparePassword } = require('../utils/passwordUtils');

// Get student profile
const getStudentProfile = (req, res) => {
  try {
    const studentId = req.user.userId;

    db.get(
      `SELECT id, username, email, phone, hostel_register_number, room_number, floor, created_at 
       FROM students 
       WHERE id = ?`,
      [studentId],
      (err, student) => {
        if (err || !student) {
          return res.status(404).json({
            success: false,
            message: 'Student not found'
          });
        }

        res.json({
          success: true,
          data: student
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

// Get warden profile
const getWardenProfile = (req, res) => {
  try {
    const wardenId = req.user.userId;

    db.get(
      `SELECT id, username, email, phone, hostel_name, created_at 
       FROM wardens 
       WHERE id = ?`,
      [wardenId],
      (err, warden) => {
        if (err || !warden) {
          return res.status(404).json({
            success: false,
            message: 'Warden not found'
          });
        }

        res.json({
          success: true,
          data: warden
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

// Update student profile
const updateStudentProfile = (req, res) => {
  try {
    const studentId = req.user.userId;
    const { email, phone } = req.body;

    db.run(
      `UPDATE students 
       SET email = ?, phone = ?, updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [email || null, phone || null, studentId],
      (err) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error updating profile'
          });
        }

        res.json({
          success: true,
          message: 'Profile updated successfully'
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

// Change password (Student and Warden)
const changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;
    const role = req.user.role;
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Old and new passwords are required'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters'
      });
    }

    const table = role === 'student' ? 'students' : 'wardens';

    db.get(`SELECT password FROM ${table} WHERE id = ?`, [userId], async (err, user) => {
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const isPasswordValid = await comparePassword(oldPassword, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Old password is incorrect'
        });
      }

      const hashedPassword = await hashPassword(newPassword);

      db.run(
        `UPDATE ${table} 
         SET password = ?, updated_at = CURRENT_TIMESTAMP 
         WHERE id = ?`,
        [hashedPassword, userId],
        (err) => {
          if (err) {
            return res.status(500).json({
              success: false,
              message: 'Error changing password'
            });
          }

          res.json({
            success: true,
            message: 'Password changed successfully'
          });
        }
      );
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

// Delete account (Student and Warden)
const deleteAccount = (req, res) => {
  try {
    const userId = req.user.userId;
    const role = req.user.role;
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required to delete account'
      });
    }

    const table = role === 'student' ? 'students' : 'wardens';

    db.get(`SELECT password FROM ${table} WHERE id = ?`, [userId], async (err, user) => {
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const isPasswordValid = await comparePassword(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Password is incorrect'
        });
      }

      db.run(`DELETE FROM ${table} WHERE id = ?`, [userId], (err) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error deleting account'
          });
        }

        res.json({
          success: true,
          message: 'Account deleted successfully'
        });
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

module.exports = {
  getStudentProfile,
  getWardenProfile,
  updateStudentProfile,
  changePassword,
  deleteAccount
};
