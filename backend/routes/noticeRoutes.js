// backend/routes/noticeRoutes.js
const express = require('express');
const router = express.Router();
const noticeController = require('../controllers/noticeController');
const { verifyAuth, verifyStudent, verifyWarden } = require('../middleware/auth');

// Student routes
router.get('/view', verifyAuth, verifyStudent, noticeController.getNotices);

// Warden routes
router.post('/create', verifyAuth, verifyWarden, noticeController.createNotice);
router.get('/my-notices', verifyAuth, verifyWarden, noticeController.getWardenNotices);
router.put('/update/:noticeId', verifyAuth, verifyWarden, noticeController.updateNotice);
router.delete('/delete/:noticeId', verifyAuth, verifyWarden, noticeController.deleteNotice);

module.exports = router;
