// backend/middleware/auth.js
const { verifyToken } = require('../utils/tokenUtils');

// Verify JWT middleware
const verifyAuth = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

// Verify student role
const verifyStudent = (req, res, next) => {
  if (req.user.role !== 'student') {
    return res.status(403).json({
      success: false,
      message: 'Only students can access this resource'
    });
  }
  next();
};

// Verify warden role
const verifyWarden = (req, res, next) => {
  if (req.user.role !== 'warden') {
    return res.status(403).json({
      success: false,
      message: 'Only wardens can access this resource'
    });
  }
  next();
};

module.exports = {
  verifyAuth,
  verifyStudent,
  verifyWarden
};
