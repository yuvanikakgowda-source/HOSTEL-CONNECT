const express = require('express');
const axios = require('axios');
const { verifyAuth, verifyStudent } = require('../middleware/auth');

const router = express.Router();
const RECOGNIZER_URL = process.env.RECOGNIZER_URL || 'http://localhost:6000';

router.post('/register-face', verifyAuth, verifyStudent, async (req, res) => {
  try {
    const response = await axios.post(
      `${RECOGNIZER_URL}/api/register-face`,
      {
        student_id: req.user.userId,
        camera_index: req.body.camera_index ?? 0,
        sample_count: req.body.sample_count ?? 5,
        timeout_seconds: req.body.timeout_seconds ?? 30,
        show_window: req.body.show_window ?? true,
      },
      { timeout: 60000 }
    );

    return res.status(response.status).json(response.data);
  } catch (error) {
    const status = error.response?.status || 500;
    const message = error.response?.data?.message || error.message;
    return res.status(status).json({
      success: false,
      cameraAccessDenied: status === 403,
      message: status === 403 ? message : `Face registration failed: ${message}`
    });
  }
});

router.post('/start-scan', verifyAuth, verifyStudent, async (req, res) => {
  try {
    const response = await axios.post(
      `${RECOGNIZER_URL}/api/start-scan`,
      {
        camera_index: req.body.camera_index ?? 0,
        timeout_seconds: req.body.timeout_seconds ?? 30,
        capture_interval: req.body.capture_interval ?? 0.2,
        tolerance: req.body.tolerance ?? 0.55,
        show_window: req.body.show_window ?? true,
      },
      { timeout: 60000 }
    );

    return res.status(response.status).json(response.data);
  } catch (error) {
    const status = error.response?.status || 500;
    const message = error.response?.data?.message || error.message;
    return res.status(status).json({
      success: false,
      recognized: false,
      cameraAccessDenied: status === 403,
      message: status === 403 ? message : `Face scan failed: ${message}`
    });
  }
});

router.get('/attendance-records', verifyAuth, async (req, res) => {
  try {
    const response = await axios.get(`${RECOGNIZER_URL}/api/attendance-records`, {
      params: {
        student_id: req.query.student_id,
        date: req.query.date,
      },
      timeout: 20000,
    });
    return res.status(response.status).json(response.data);
  } catch (error) {
    const status = error.response?.status || 500;
    const message = error.response?.data?.message || error.message;
    return res.status(status).json({ success: false, message: `Retrieve attendance failed: ${message}` });
  }
});

module.exports = router;
