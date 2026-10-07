// backend/routes/profileRoutes.js
const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const { verifyAuth, verifyStudent, verifyWarden } = require('../middleware/auth');

// Student routes
router.get('/student', verifyAuth, verifyStudent, profileController.getStudentProfile);
router.put('/student/update', verifyAuth, verifyStudent, profileController.updateStudentProfile);

// Warden routes
router.get('/warden', verifyAuth, verifyWarden, profileController.getWardenProfile);

// Both
router.post('/change-password', verifyAuth, profileController.changePassword);
router.post('/delete-account', verifyAuth, profileController.deleteAccount);

module.exports = router;
