// backend/routes/messMenuRoutes.js
const express = require('express');
const router = express.Router();
const messMenuController = require('../controllers/messMenuController');
const { verifyAuth, verifyWarden } = require('../middleware/auth');

// All users can view
router.get('/view', messMenuController.getMessMenu);

// Warden only
router.put('/update', verifyAuth, verifyWarden, messMenuController.updateMessMenu);
router.post('/upload', verifyAuth, verifyWarden, messMenuController.uploadMessMenu);

module.exports = router;
