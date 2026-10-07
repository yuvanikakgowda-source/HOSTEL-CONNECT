// backend/controllers/messMenuController.js
const db = require('../config/database');

// Get mess menu
const getMessMenu = (req, res) => {
  try {
    db.all(
      `SELECT * FROM mess_menu 
       ORDER BY 
       CASE day_of_week
         WHEN 'Monday' THEN 1
         WHEN 'Tuesday' THEN 2
         WHEN 'Wednesday' THEN 3
         WHEN 'Thursday' THEN 4
         WHEN 'Friday' THEN 5
         WHEN 'Saturday' THEN 6
         WHEN 'Sunday' THEN 7
       END,
       CASE meal_type
         WHEN 'Breakfast' THEN 1
         WHEN 'Lunch' THEN 2
         WHEN 'Dinner' THEN 3
       END`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Error fetching mess menu'
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

// Update or create mess menu item (Warden)
const updateMessMenu = (req, res) => {
  try {
    const { day_of_week, meal_type, menu_item } = req.body;

    if (!day_of_week || !meal_type || !menu_item) {
      return res.status(400).json({
        success: false,
        message: 'Day, meal type, and menu item are required'
      });
    }

    const validDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const validMeals = ['Breakfast', 'Lunch', 'Dinner'];

    if (!validDays.includes(day_of_week) || !validMeals.includes(meal_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid day or meal type'
      });
    }

    // Check if entry exists
    db.get(
      `SELECT id FROM mess_menu WHERE day_of_week = ? AND meal_type = ?`,
      [day_of_week, meal_type],
      (err, row) => {
        if (row) {
          // Update existing
          db.run(
            `UPDATE mess_menu 
             SET menu_item = ?, updated_at = CURRENT_TIMESTAMP 
             WHERE day_of_week = ? AND meal_type = ?`,
            [menu_item, day_of_week, meal_type],
            (err) => {
              if (err) {
                return res.status(500).json({
                  success: false,
                  message: 'Error updating menu'
                });
              }

              res.json({
                success: true,
                message: 'Menu updated successfully'
              });
            }
          );
        } else {
          // Insert new
          db.run(
            `INSERT INTO mess_menu (day_of_week, meal_type, menu_item)
             VALUES (?, ?, ?)`,
            [day_of_week, meal_type, menu_item],
            function (err) {
              if (err) {
                return res.status(500).json({
                  success: false,
                  message: 'Error creating menu item'
                });
              }

              res.status(201).json({
                success: true,
                message: 'Menu item created successfully'
              });
            }
          );
        }
      }
    );
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

// Upload mess menu (bulk update)
const uploadMessMenu = (req, res) => {
  try {
    const { menu } = req.body; // Array of {day_of_week, meal_type, menu_item}

    if (!Array.isArray(menu) || menu.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Menu array is required'
      });
    }

    let completed = 0;
    let errors = [];

    menu.forEach((item, index) => {
      const { day_of_week, meal_type, menu_item } = item;

      if (!day_of_week || !meal_type || !menu_item) {
        errors.push(`Item ${index + 1} is missing required fields`);
        completed++;
        return;
      }

      db.get(
        `SELECT id FROM mess_menu WHERE day_of_week = ? AND meal_type = ?`,
        [day_of_week, meal_type],
        (err, row) => {
          if (row) {
            db.run(
              `UPDATE mess_menu 
               SET menu_item = ?, updated_at = CURRENT_TIMESTAMP 
               WHERE day_of_week = ? AND meal_type = ?`,
              [menu_item, day_of_week, meal_type],
              (err) => {
                completed++;
              }
            );
          } else {
            db.run(
              `INSERT INTO mess_menu (day_of_week, meal_type, menu_item)
               VALUES (?, ?, ?)`,
              [day_of_week, meal_type, menu_item],
              (err) => {
                completed++;
              }
            );
          }
        }
      );
    });

    // Wait for all operations
    const checkComplete = setInterval(() => {
      if (completed === menu.length) {
        clearInterval(checkComplete);
        res.json({
          success: true,
          message: 'Uploaded Successfully',
          errors: errors.length > 0 ? errors : undefined
        });
      }
    }, 100);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

module.exports = {
  getMessMenu,
  updateMessMenu,
  uploadMessMenu
};
