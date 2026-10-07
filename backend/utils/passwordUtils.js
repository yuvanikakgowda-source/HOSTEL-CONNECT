// backend/utils/passwordUtils.js
const bcrypt = require('bcryptjs');

// Hash password
const hashPassword = async (password) => {
  try {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    return hashedPassword;
  } catch (error) {
    throw new Error('Error hashing password: ' + error.message);
  }
};

// Compare passwords
const comparePassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (error) {
    throw new Error('Error comparing password: ' + error.message);
  }
};

module.exports = {
  hashPassword,
  comparePassword
};
