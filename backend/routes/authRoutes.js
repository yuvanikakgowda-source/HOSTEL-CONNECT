// backend/routes/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Registration routes
router.post('/register/student', authController.registerStudent);
router.post('/register/warden', authController.registerWarden);

// Login routes
router.post('/login/student', authController.loginStudent);
router.post('/login/warden', authController.loginWarden);

module.exports = router;
