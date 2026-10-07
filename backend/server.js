// backend/server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const db = require('./config/database');
const errorHandler = require('./middleware/errorHandler');

// Import routes
const authRoutes = require('./routes/authRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const faceRecognitionRoutes = require('./routes/faceRecognitionRoutes');
const complaintRoutes = require('./routes/complaintRoutes');
const noticeRoutes = require('./routes/noticeRoutes');
const messMenuRoutes = require('./routes/messMenuRoutes');
const roomRoutes = require('./routes/roomRoutes');
const profileRoutes = require('./routes/profileRoutes');
const searchRoutes = require('./routes/searchRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/face', faceRecognitionRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/notices', noticeRoutes);
app.use('/api/mess-menu', messMenuRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/search', searchRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Hostel Connect Backend API is running',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use(errorHandler);

const PORT = process.env.PORT || 5001;

app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════╗
║   HOSTEL CONNECT - Backend Server    ║
║          Running on port ${PORT}              ║
╚══════════════════════════════════════╝
  `);
  console.log(`Environment: ${process.env.NODE_ENV}`);
  console.log(`API Base URL: http://localhost:${PORT}/api`);
});

module.exports = app;
