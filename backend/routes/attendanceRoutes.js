// backend/routes/attendanceRoutes.js
const express = require('express');
const router = express.Router();
const attendanceController = require('../controllers/attendanceController');
const { verifyAuth, verifyStudent, verifyWarden } = require('../middleware/auth');

// Student routes
router.get('/my-attendance', verifyAuth, verifyStudent, attendanceController.getStudentAttendance);

// Warden routes
router.get('/all', verifyAuth, verifyWarden, attendanceController.getAllAttendance);
router.get('/student/:studentId', verifyAuth, verifyWarden, attendanceController.getAttendanceByStudent);
router.get('/statistics', verifyAuth, verifyWarden, attendanceController.getAttendanceStats);

module.exports = router;
