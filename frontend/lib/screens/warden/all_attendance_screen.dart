import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/attendance_model.dart';
import '../../services/api_service.dart';

class AllAttendanceScreen extends ConsumerStatefulWidget {
  const AllAttendanceScreen({super.key});

  @override
  ConsumerState<AllAttendanceScreen> createState() =>
      _AllAttendanceScreenState();
}

class _AllAttendanceScreenState extends ConsumerState<AllAttendanceScreen> {
  final _dateController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _userIdController = TextEditingController();
  List<AttendanceModel> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final query = <String, dynamic>{};
      if (_dateController.text.trim().isNotEmpty) {
        query['date'] = _dateController.text.trim();
      }
      if (_monthController.text.trim().isNotEmpty) {
        query['month'] = _monthController.text.trim();
      }
      if (_yearController.text.trim().isNotEmpty) {
        query['year'] = _yearController.text.trim();
      }
      if (_userIdController.text.trim().isNotEmpty) {
        query['userId'] = _userIdController.text.trim();
      }

      final response = await ApiService().get(
        '/attendance/all',
        queryParameters: query,
      );
      final data = response.data['data'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _records = data
            .map((item) => AttendanceModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _clearFilters() {
    _dateController.clear();
    _monthController.clear();
    _yearController.clear();
    _userIdController.clear();
    _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warden-dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _filterField(_dateController, 'Date', '06-06-2026'),
                _filterField(_monthController, 'Month', 'June'),
                _filterField(_yearController, 'Year', '2026'),
                _filterField(_userIdController, 'User ID', 'STU001'),
                ElevatedButton.icon(
                  onPressed: _loadAttendance,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Apply'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _filterField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _loadAttendance(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_records.isEmpty) {
      return const Center(child: Text('No attendance records'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('User ID')),
            DataColumn(label: Text('Student Name')),
            DataColumn(label: Text('Year')),
            DataColumn(label: Text('Month')),
            DataColumn(label: Text('Day')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Status')),
          ],
          rows: _records
              .map(
                (record) => DataRow(
                  cells: [
                    DataCell(Text(record.userId ?? record.hostelRegisterNumber ?? '')),
                    DataCell(Text(record.studentName ?? record.username ?? '')),
                    DataCell(Text(record.year?.toString() ?? '')),
                    DataCell(Text(record.month ?? '')),
                    DataCell(Text(record.day)),
                    DataCell(Text(record.date)),
                    DataCell(Text(record.time ?? record.timeMarked ?? '')),
                    DataCell(Text(record.status)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _userIdController.dispose();
    super.dispose();
  }
}
