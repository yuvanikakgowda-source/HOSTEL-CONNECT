// backend/routes/roomRoutes.js
const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');
const { verifyAuth, verifyStudent, verifyWarden } = require('../middleware/auth');

// Student routes
router.get('/my-room', verifyAuth, verifyStudent, roomController.getStudentRoom);

// Warden routes
router.get('/all', verifyAuth, verifyWarden, roomController.getAllRooms);
router.get('/detailed', verifyAuth, verifyWarden, roomController.getRoomsWithStudents);
router.get('/unallocated', verifyAuth, verifyWarden, roomController.getUnallocatedStudents);
router.get('/filter/floor', verifyAuth, verifyWarden, roomController.filterRoomsByFloor);
router.get('/filter/status', verifyAuth, verifyWarden, roomController.filterRoomsByStatus);
router.get('/search', verifyAuth, verifyWarden, roomController.searchRooms);
router.post('/create', verifyAuth, verifyWarden, roomController.createRoom);
router.put('/allocate/:studentId', verifyAuth, verifyWarden, roomController.updateRoomAllocation);
router.put('/remove/:studentId', verifyAuth, verifyWarden, roomController.removeRoomAllocation);
router.put('/:roomId', verifyAuth, verifyWarden, roomController.updateRoom);

module.exports = router;
