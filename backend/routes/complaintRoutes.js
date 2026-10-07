// backend/routes/complaintRoutes.js
const express = require('express');
const router = express.Router();
const complaintController = require('../controllers/complaintController');
const { verifyAuth, verifyStudent, verifyWarden } = require('../middleware/auth');

// Student routes
router.post('/file', verifyAuth, verifyStudent, complaintController.fileComplaint);
router.get('/my-complaints', verifyAuth, verifyStudent, complaintController.getStudentComplaints);
router.put('/update/:complaintId', verifyAuth, verifyStudent, complaintController.updateComplaint);
router.delete('/delete/:complaintId', verifyAuth, verifyStudent, complaintController.deleteComplaint);

// Warden routes
router.get('/all', verifyAuth, verifyWarden, complaintController.getAllComplaints);
router.put('/status/:complaintId', verifyAuth, verifyWarden, complaintController.updateComplaintStatus);

module.exports = router;
