import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    _loadData();
  }

  Future<void> _loadData() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    await attendanceProvider.loadAttendanceHistory(
      page: 1,
      month: _selectedMonth,
      year: _selectedYear,
    );
    _currentPage = 1;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    await attendanceProvider.loadAttendanceHistory(
      page: _currentPage + 1,
      month: _selectedMonth,
      year: _selectedYear,
    );

    setState(() {
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  Future<void> _showFilterDialog() async {
    final now = DateTime.now();
    int? tempMonth = _selectedMonth;
    int? tempYear = _selectedYear;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Riwayat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month Selector
              DropdownButtonFormField<int?>(
                value: tempMonth,
                decoration: const InputDecoration(
                  labelText: 'Bulan',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Bulan'),
                  ),
                  ...List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(
                        DateFormat(
                          'MMMM',
                          'id_ID',
                        ).format(DateTime(2024, month)),
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    tempMonth = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Year Selector
              DropdownButtonFormField<int?>(
                value: tempYear,
                decoration: const InputDecoration(
                  labelText: 'Tahun',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Tahun'),
                  ),
                  ...List.generate(5, (index) {
                    final year = now.year - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    tempYear = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedMonth = tempMonth;
                  _selectedYear = tempYear;
                });
                _loadData();
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          if (attendanceProvider.isLoading &&
              attendanceProvider.attendanceHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (attendanceProvider.attendanceHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat absensi',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attendanceProvider.attendanceHistory.length + 1,
              itemBuilder: (context, index) {
                if (index == attendanceProvider.attendanceHistory.length) {
                  // Load more button/indicator
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isLoadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : TextButton(
                            onPressed: _loadMore,
                            child: const Text('Muat Lebih Banyak'),
                          ),
                  );
                }

                final attendance = attendanceProvider.attendanceHistory[index];
                return _buildAttendanceCard(attendance);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final isComplete = attendance.clockOut != null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'EEEE, d MMMM y',
                    'id_ID',
                  ).format(attendance.clockIn),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(attendance.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(attendance.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStatusColor(attendance.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Clock In
            Row(
              children: [
                const Icon(Icons.login, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Clock In: ${DateFormat('HH:mm', 'id_ID').format(attendance.clockIn)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Clock Out
            if (isComplete) ...[
              Row(
                children: [
                  const Icon(Icons.logout, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Clock Out: ${DateFormat('HH:mm', 'id_ID').format(attendance.clockOut!)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Durasi: ${attendance.formattedDuration}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Belum Clock Out',
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ],
              ),

            // Notes
            if (attendance.clockInNotes != null ||
                attendance.clockOutNotes != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              if (attendance.clockInNotes != null) ...[
                const Text(
                  'Catatan Clock In:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  attendance.clockInNotes!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
              if (attendance.clockOutNotes != null) ...[
                const SizedBox(height: 4),
                const Text(
                  'Catatan Clock Out:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  attendance.clockOutNotes!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
      case 'present':
        return Colors.green;
      case 'terlambat':
      case 'late':
        return Colors.orange;
      case 'alpha':
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'absent':
        return 'Alpha';
      default:
        return status;
    }
  }
}
