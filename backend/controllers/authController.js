// backend/controllers/authController.js
const db = require('../config/database');
const { hashPassword, comparePassword } = require('../utils/passwordUtils');
const { generateToken } = require('../utils/tokenUtils');
const { validateEmail, validatePassword, validateUsername, validateRegisterNumber } = require('../utils/validators');

// Student Registration
const registerStudent = async (req, res) => {
  try {
    const { username, password, hostel_register_number, email } = req.body;

    // Validate email if provided
    if (email && !validateEmail(email)) {
      return res.status(400).json({ success: false, message: 'Invalid email address' });
    }

    // Validation
    const usernameValidation = validateUsername(username);
    if (!usernameValidation.valid) {
      return res.status(400).json({
        success: false,
        message: usernameValidation.message
      });
    }

    const passwordValidation = validatePassword(password);
    if (!passwordValidation.valid) {
      return res.status(400).json({
        success: false,
        message: passwordValidation.message
      });
    }

    const registerValidation = validateRegisterNumber(hostel_register_number);
    if (!registerValidation.valid) {
      return res.status(400).json({
        success: false,
        message: registerValidation.message
      });
    }

    // Check if username already exists
    db.get('SELECT id FROM students WHERE username = ?', [username], async (err, row) => {
      if (err) {
        return res.status(500).json({
          success: false,
          message: 'Database error: ' + err.message
        });
      }

      if (row) {
        return res.status(400).json({
          success: false,
          message: 'Username already exists'
        });
      }

      // Check if register number already exists
      db.get('SELECT id FROM students WHERE hostel_register_number = ?', [hostel_register_number], async (err, row) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Database error: ' + err.message });
        }
        if (row) {
          return res.status(400).json({
            success: false,
            message: 'Hostel register number already registered'
          });
        }

        // Hash password
        const hashedPassword = await hashPassword(password);

        // Insert student credentials only. Face enrollment happens through
        // the live OpenCV registration endpoint after login.
        db.run(
          `INSERT INTO students (username, password, hostel_register_number, email)
           VALUES (?, ?, ?, ?)`,
          [username, hashedPassword, hostel_register_number, email || null],
          function (err) {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error registering student: ' + err.message
              });
            }

            const studentId = this.lastID;
            const token = generateToken(studentId, 'student');

            res.status(201).json({
              success: true,
              message: 'Student registered successfully',
              token,
              user: {
                id: studentId,
                username,
                hostel_register_number,
                role: 'student'
              }
            });
          }
        );
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

// Warden Registration
const registerWarden = async (req, res) => {
  try {
    const { username, password, email, phone, hostel_name } = req.body;

    // Validation
    const usernameValidation = validateUsername(username);
    if (!usernameValidation.valid) {
      return res.status(400).json({
        success: false,
        message: usernameValidation.message
      });
    }

    const passwordValidation = validatePassword(password);
    if (!passwordValidation.valid) {
      return res.status(400).json({
        success: false,
        message: passwordValidation.message
      });
    }

    // Check if username already exists
    db.get('SELECT id FROM wardens WHERE username = ?', [username], async (err, row) => {
      if (err) {
        return res.status(500).json({ success: false, message: 'Database error: ' + err.message });
      }
      if (row) {
        return res.status(400).json({
          success: false,
          message: 'Username already exists'
        });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Insert warden credentials only.
      db.run(
        `INSERT INTO wardens (username, password, email, phone, hostel_name)
         VALUES (?, ?, ?, ?, ?)`,
        [username, hashedPassword, email || null, phone || null, hostel_name || null],
        function (err) {
          if (err) {
              return res.status(500).json({
                success: false,
                message: 'Error registering warden: ' + err.message
              });
            }

          const token = generateToken(this.lastID, 'warden');

          res.status(201).json({
            success: true,
            message: 'Warden registered successfully',
            token,
            user: {
              id: this.lastID,
              username,
              role: 'warden'
            }
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

// Student Login
const loginStudent = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required'
      });
    }

    db.get('SELECT * FROM students WHERE username = ?', [username], async (err, student) => {
      if (err || !student) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password'
        });
      }

      const isPasswordValid = await comparePassword(password, student.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password'
        });
      }

      // Login successful if credentials match (no biometric)

      const token = generateToken(student.id, 'student');

      res.json({
        success: true,
        message: 'Login successful',
        token,
        user: {
          id: student.id,
          username: student.username,
          hostel_register_number: student.hostel_register_number,
          room_number: student.room_number,
          floor: student.floor,
          role: 'student'
        }
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error: ' + error.message
    });
  }
};

// Warden Login
const loginWarden = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required'
      });
    }

    db.get('SELECT * FROM wardens WHERE username = ?', [username], async (err, warden) => {
      if (err || !warden) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password'
        });
      }

      const isPasswordValid = await comparePassword(password, warden.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password'
        });
      }

      // Login successful if credentials match (no biometric)

      const token = generateToken(warden.id, 'warden');

      res.json({
        success: true,
        message: 'Login successful',
        token,
        user: {
          id: warden.id,
          username: warden.username,
          hostel_name: warden.hostel_name,
          role: 'warden'
        }
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
  registerStudent,
  registerWarden,
  loginStudent,
  loginWarden
};
