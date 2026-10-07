// backend/utils/validators.js
const validator = require('validator');

// Validate email
const validateEmail = (email) => {
  return validator.isEmail(email);
};

// Validate password strength
const validatePassword = (password) => {
  if (password.length < 6) {
    return { valid: false, message: 'Password must be at least 6 characters long' };
  }
  return { valid: true };
};

// Validate username
const validateUsername = (username) => {
  if (username.length < 3 || username.length > 20) {
    return { valid: false, message: 'Username must be between 3 and 20 characters' };
  }
  if (!/^[a-zA-Z0-9_-]+$/.test(username)) {
    return { valid: false, message: 'Username can only contain letters, numbers, underscore and hyphen' };
  }
  return { valid: true };
};

// Validate hostel register number
const validateRegisterNumber = (registerNumber) => {
  if (!registerNumber || registerNumber.trim().length === 0) {
    return { valid: false, message: 'Hostel register number is required' };
  }
  return { valid: true };
};

module.exports = {
  validateEmail,
  validatePassword,
  validateUsername,
  validateRegisterNumber
};
