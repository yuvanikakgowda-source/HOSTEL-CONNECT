// backend/utils/tokenUtils.js
const jwt = require('jsonwebtoken');

const getJwtSecret = () => {
  const jwtSecret = process.env.JWT_SECRET;
  if (!jwtSecret) {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('JWT_SECRET must be configured in production');
    }
    console.warn('JWT_SECRET is not set. Falling back to a development secret.');
    return 'dev_hostel_connect_secret_key';
  }
  return jwtSecret;
};

// Generate JWT token
const generateToken = (userId, role) => {
  const payload = {
    userId,
    role,
    iat: Math.floor(Date.now() / 1000)
  };

  return jwt.sign(payload, getJwtSecret(), {
    expiresIn: process.env.JWT_EXPIRE || '7d'
  });
};

// Verify JWT token
const verifyToken = (token) => {
  try {
    return jwt.verify(token, getJwtSecret());
  } catch (error) {
    throw new Error('Invalid token: ' + error.message);
  }
};

// Decode token without verification (for testing)
const decodeToken = (token) => {
  return jwt.decode(token);
};

module.exports = {
  generateToken,
  verifyToken,
  decodeToken
};
