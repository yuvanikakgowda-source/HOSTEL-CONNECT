// backend/controllers/noticeController.js
const db = require('../config/database');

// Create notice (Warden)
const createNotice = (req, res) => {
  try {
    const wardenId = req.user.userId;
    const { title, content } = req.body;

    if (!title || !content) {
      return res.status(400).json({
        success: false,
        message: 'Title and content are required'
      });
    }

    const today = new Date().toISOString().split('T')[0];

    db.run(
      `INSERT INTO notices (warden_id, title, content, date_posted)
       VALUES (?, ?, ?, ?)`,
      [wardenId, title, content, today],
      function (err) {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error creating notice'
          });
        }

        res.status(201).json({
          success: true,
          message: 'Notice created successfully',
          data: {
            id: this.lastID,
            warden_id: wardenId,
            title,
            content,
            date_posted: today
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

// Get all notices (Students)
const getNotices = (req, res) => {
  try {
    db.all(
      `SELECT n.*, w.username 
       FROM notices n
       JOIN wardens w ON n.warden_id = w.id
       ORDER BY n.date_posted DESC`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching notices'
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

// Get all notices (Warden)
const getWardenNotices = (req, res) => {
  try {
    const wardenId = req.user.userId;

    db.all(
      `SELECT * FROM notices 
       WHERE warden_id = ? 
       ORDER BY date_posted DESC`,
      [wardenId],
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching notices'
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

// Update notice (Warden)
const updateNotice = (req, res) => {
  try {
    const wardenId = req.user.userId;
    const { noticeId } = req.params;
    const { title, content } = req.body;

    if (!title || !content) {
      return res.status(400).json({
        success: false,
        message: 'Title and content are required'
      });
    }

    // Verify ownership
    db.get(
      'SELECT id FROM notices WHERE id = ? AND warden_id = ?',
      [noticeId, wardenId],
      (err, notice) => {
        if (!notice) {
          return res.status(403).json({
            success: false,
            message: 'You can only edit your own notices'
          });
        }

        db.run(
          `UPDATE notices 
           SET title = ?, content = ?, updated_at = CURRENT_TIMESTAMP 
           WHERE id = ?`,
          [title, content, noticeId],
          (err) => {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error updating notice'
              });
            }

            res.json({
              success: true,
              message: 'Notice updated successfully'
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

// Delete notice (Warden)
const deleteNotice = (req, res) => {
  try {
    const wardenId = req.user.userId;
    const { noticeId } = req.params;

    // Verify ownership
    db.get(
      'SELECT id FROM notices WHERE id = ? AND warden_id = ?',
      [noticeId, wardenId],
      (err, notice) => {
        if (!notice) {
          return res.status(403).json({
            success: false,
            message: 'You can only delete your own notices'
          });
        }

        db.run(
          'DELETE FROM notices WHERE id = ?',
          [noticeId],
          (err) => {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error deleting notice'
              });
            }

            res.json({
              success: true,
              message: 'Notice deleted successfully'
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

module.exports = {
  createNotice,
  getNotices,
  getWardenNotices,
  updateNotice,
  deleteNotice
};
