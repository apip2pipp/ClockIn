import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';
import '../widgets/main_layout.dart';

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
                initialValue: tempMonth,
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
                initialValue: tempYear,
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
    return MainLayout(
      selectedIndex: 1,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with gradient
              _buildHeader(context),

              // Main content
              SliverToBoxAdapter(
                child: Consumer<AttendanceProvider>(
                  builder: (context, attendanceProvider, child) {
                    if (attendanceProvider.isLoading &&
                        attendanceProvider.attendanceHistory.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(100),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (attendanceProvider.attendanceHistory.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF26667F,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Belum ada riwayat absensi',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(25),
                        itemCount:
                            attendanceProvider.attendanceHistory.length + 1,
                        itemBuilder: (context, index) {
                          if (index ==
                              attendanceProvider.attendanceHistory.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: _isLoadingMore
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Center(
                                      child: OutlinedButton.icon(
                                        onPressed: _loadMore,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Muat Lebih Banyak'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF26667F,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF26667F),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            );
                          }

                          final attendance =
                              attendanceProvider.attendanceHistory[index];
                          return _buildAttendanceCard(attendance);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF80CE70), Color(0xFF26667F)],
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE5E7EB).withOpacity(0.5),
              width: 0.6,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ClockIn Logo
                Row(
                  children: [
                    SizedBox(
                      width: 47,
                      height: 47,
                      child: Image.asset(
                        'assets/icon_login.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Riwayat Absensi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Filter Button
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final isComplete = attendance.clockOut != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withOpacity(0.4),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat(
                          'EEEE, d MMMM y',
                          'id_ID',
                        ).format(attendance.clockIn),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF181F3E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          attendance.status,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(
                            attendance.status,
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(attendance.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(attendance.status),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Clock In
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.login,
                        size: 18,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clock In',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat(
                            'HH:mm',
                            'id_ID',
                          ).format(attendance.clockIn),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF181F3E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Clock Out
                if (isComplete) ...[
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clock Out',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat(
                              'HH:mm',
                              'id_ID',
                            ).format(attendance.clockOut!),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF181F3E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Divider(
                    color: const Color(0xFFE5E7EB).withOpacity(0.3),
                    thickness: 0.6,
                  ),

                  const SizedBox(height: 12),

                  // Duration
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26667F).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timer,
                          size: 18,
                          color: Color(0xFF26667F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durasi Kerja',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            attendance.formattedWorkDuration,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF124170),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Belum Clock Out',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                // Notes
                if (attendance.clockInNotes != null ||
                    attendance.clockOutNotes != null) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: const Color(0xFFE5E7EB).withOpacity(0.3),
                    thickness: 0.6,
                  ),
                  const SizedBox(height: 12),
                  if (attendance.clockInNotes != null) ...[
                    Text(
                      'Catatan Clock In:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attendance.clockInNotes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                  if (attendance.clockOutNotes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Catatan Clock Out:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attendance.clockOutNotes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on_time':
      case 'hadir':
      case 'present':
        return Colors.green;
      case 'late':
      case 'terlambat':
        return Colors.orange;
      case 'absent':
      case 'alpha':
        return Colors.red;
      case 'half_day':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'on_time':
      case 'present':
        return 'Hadir';
      case 'late':
      case 'terlambat':
        return 'Terlambat';
      case 'absent':
      case 'alpha':
        return 'Alpha';
      case 'half_day':
        return 'Setengah Hari';
      default:
        return status;
    }
  }
}