// backend/routes/searchRoutes.js
const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const { verifyAuth, verifyWarden } = require('../middleware/auth');

// Warden only
router.get('/students', verifyAuth, verifyWarden, searchController.searchStudents);
router.get('/student/:studentId', verifyAuth, verifyWarden, searchController.getStudentDetails);

module.exports = router;
