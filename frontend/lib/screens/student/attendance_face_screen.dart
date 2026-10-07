// frontend/lib/screens/student/attendance_face_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/api_service.dart';
import '../../providers/attendance_provider.dart';

class AttendanceFaceScreen extends ConsumerStatefulWidget {
  const AttendanceFaceScreen({super.key});

  @override
  ConsumerState<AttendanceFaceScreen> createState() =>
      _AttendanceFaceScreenState();
}

class _AttendanceFaceScreenState extends ConsumerState<AttendanceFaceScreen> {
  bool _isScanning = false;
  bool _isRegistering = false;
  String _statusMessage =
      'Register your face once, then start the live webcam scan to mark attendance.';
  Color _statusColor = Colors.blueGrey;
  Map<String, dynamic>? _scanResult;

  Future<bool> _ensureCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }

      setState(() {
        _statusMessage =
            'Camera permission denied. Enable camera access before marking attendance.';
        _statusColor = Colors.red;
        _scanResult = null;
      });
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<void> _registerFace() async {
    if (_isScanning || _isRegistering) return;

    setState(() {
      _isRegistering = true;
      _statusMessage = 'Starting live face registration...';
      _statusColor = Colors.blue;
      _scanResult = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.post('/face/register-face', {});
      if (!mounted) return;

      final data = Map<String, dynamic>.from(response.data as Map);

      setState(() {
        _statusMessage = data['message'] ?? 'Face registered successfully.';
        _statusColor = data['success'] == true ? Colors.green : Colors.red;
        _scanResult = data;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Face registration failed: ${error.toString()}';
        _statusColor = Colors.red;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  Future<void> _startFaceScan() async {
    if (_isScanning) return;
    final hasCameraPermission = await _ensureCameraPermission();
    if (!hasCameraPermission) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Starting webcam face scan...';
      _statusColor = Colors.blue;
      _scanResult = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.post('/face/start-scan', {});
      if (!mounted) return;

      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['success'] == true && data['recognized'] == true) {
        setState(() {
          _statusMessage =
              'Recognized ${data['username'] ?? 'student'}. Attendance marked.';
          _statusColor = Colors.green;
          _scanResult = data;
        });

        final _ = ref.refresh(attendanceProvider);
      } else if (data['success'] == true && data['recognized'] == false) {
        final reason = data['reason'] ?? 'Unknown person';
        setState(() {
          _statusMessage = reason == 'unknown'
              ? 'Unknown person. Attendance was not marked.'
              : 'Scan result: $reason';
          _statusColor =
              reason == 'multiple_faces' ? Colors.orange : Colors.red;
          _scanResult = data;
        });
      } else {
        setState(() {
          _statusMessage = data['message'] ?? 'Scan failed. Please try again.';
          _statusColor = Colors.red;
          _scanResult = data;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Scan failed: ${error.toString()}';
        _statusColor = Colors.red;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/student-dashboard');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Webcam Attendance Scanner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'The webcam service will scan the live camera feed and automatically mark attendance when a registered student face is recognized.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _isRegistering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1),
              label: Text(_isRegistering ? 'Registering...' : 'Register Face'),
              onPressed: _isScanning || _isRegistering ? null : _registerFace,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: _isScanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_isScanning ? 'Scanning...' : 'Start Face Scan'),
              onPressed: _isScanning || _isRegistering ? null : _startFaceScan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: TextStyle(color: _statusColor),
                  ),
                  if (_scanResult != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Details: ${_scanResult!['message'] ?? 'No details available'}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final _ = ref.refresh(attendanceProvider);
                setState(() {
                  _statusMessage =
                      'Refreshed attendance records. Use Start Scan to update again.';
                  _statusColor = Colors.blueGrey;
                });
              },
              child: const Text('Refresh Attendance Records'),
            ),
            const SizedBox(height: 28),
            const Text(
              'Attendance History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ref.watch(attendanceProvider).when(
                  data: (records) {
                    if (records.isEmpty) {
                      return const Text('No attendance history available.');
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Day')),
                          DataColumn(label: Text('Month')),
                          DataColumn(label: Text('Year')),
                          DataColumn(label: Text('Time')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: records
                            .map(
                              (record) => DataRow(
                                cells: [
                                  DataCell(Text(record.date)),
                                  DataCell(Text(record.day)),
                                  DataCell(Text(record.month ?? '')),
                                  DataCell(Text(record.year?.toString() ?? '')),
                                  DataCell(Text(record.time ?? record.timeMarked ?? '')),
                                  DataCell(Text(record.status)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading attendance history: $err'),
                ),
          ],
        ),
      ),
    );
  }
}
