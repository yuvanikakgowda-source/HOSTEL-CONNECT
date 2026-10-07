import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/attendance_model.dart';
import '../../services/api_service.dart';

class StudentSearchScreen extends ConsumerStatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  ConsumerState<StudentSearchScreen> createState() =>
      _StudentSearchScreenState();
}

class _StudentSearchScreenState extends ConsumerState<StudentSearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final response = await ApiService().get(
        '/search/students',
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        setState(() => _searchResults = response.data['data'] ?? []);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => _isSearching = false);
  }

  void _openProfile(Map<String, dynamic> student) {
    final userId = student['hostel_register_number']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (_) => _StudentProfileDialog(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Students'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warden-dashboard'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by student name or User ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final student = Map<String, dynamic>.from(
                            _searchResults[index] as Map,
                          );
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(student['username'] ?? 'Unknown'),
                              subtitle: Text(
                                student['hostel_register_number'] ?? 'N/A',
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () => _openProfile(student),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _StudentProfileDialog extends StatefulWidget {
  final String userId;

  const _StudentProfileDialog({required this.userId});

  @override
  State<_StudentProfileDialog> createState() => _StudentProfileDialogState();
}

class _StudentProfileDialogState extends State<_StudentProfileDialog> {
  final _dateController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _userIdController = TextEditingController();
  Map<String, dynamic>? _details;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userIdController.text = widget.userId;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await ApiService().get('/search/student/${widget.userId}');
      if (!mounted) return;
      setState(
          () => _details = Map<String, dynamic>.from(response.data['data']));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 900,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return SizedBox(
        height: 220,
        child: Center(child: Text('Error: $_error')),
      );
    }

    final student = Map<String, dynamic>.from(_details?['student'] ?? {});
    final room = _details?['roomAllocation'] == null
        ? null
        : Map<String, dynamic>.from(_details?['roomAllocation']);
    final attendance = (_details?['attendanceHistory'] as List? ?? [])
        .map((item) => AttendanceModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .where(_matchesFilters)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Student Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailsCard(student, room),
          const SizedBox(height: 20),
          const Text(
            'Attendance History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _filterField(_dateController, 'Date', '06-06-2026'),
              _filterField(_monthController, 'Month', 'June'),
              _filterField(_yearController, 'Year', '2026'),
              SizedBox(
                width: 180,
                child: TextField(
                  readOnly: true,
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student User ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.filter_alt),
                label: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _attendanceTable(attendance),
        ],
      ),
    );
  }

  Widget _detailsCard(
      Map<String, dynamic> student, Map<String, dynamic>? room) {
    final allocation = room == null
        ? 'Not allocated'
        : 'Floor ${room['floor']}, Room ${room['room_number']} (${room['room_type']})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Student Name', student['username']),
            _detailRow('User ID', student['hostel_register_number']),
            _detailRow('Email', student['email']),
            _detailRow('Phone Number', student['phone']),
            _detailRow('Room Allocation', allocation),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
              child: Text(value?.toString().isEmpty == false
                  ? value.toString()
                  : 'N/A')),
        ],
      ),
    );
  }

  Widget _filterField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => setState(() {}),
      ),
    );
  }

  bool _matchesFilters(AttendanceModel record) {
    final date = _dateController.text.trim();
    final month = _monthController.text.trim();
    final year = _yearController.text.trim();
    final userId = _userIdController.text.trim();
    return (date.isEmpty || record.date == date) &&
        (month.isEmpty || record.month == month) &&
        (year.isEmpty || record.year?.toString() == year) &&
        (userId.isEmpty || record.userId == userId);
  }

  Widget _attendanceTable(List<AttendanceModel> attendance) {
    if (attendance.isEmpty) {
      return const Text('No attendance records found');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Month')),
          DataColumn(label: Text('Day')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Status')),
        ],
        rows: attendance
            .map(
              (record) => DataRow(
                cells: [
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
