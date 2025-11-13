import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'clock_in_screen.dart';
import 'attendance_history_screen.dart';
import 'leave_request_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  String _currentTime = '';
  String _selectedZone = 'WIB';

  @override
  void initState() {
    super.initState();
    _loadData();
    _startClock();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    await attendanceProvider.loadTodayAttendance();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    DateTime now = DateTime.now();

    // Atur perbedaan zona waktu manual
    switch (_selectedZone) {
      case 'WITA':
        now = now.add(const Duration(hours: 1)); // WIB + 1
        break;
      case 'WIT':
        now = now.add(const Duration(hours: 2)); // WIB + 2
        break;
      default:
        break; // WIB = default
    }

    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer2<AuthProvider, AttendanceProvider>(
          builder: (context, authProvider, attendanceProvider, child) {
            final user = authProvider.user;
            final company = authProvider.company;
            final todayAttendance = attendanceProvider.todayAttendance;

            if (attendanceProvider.isLoading && todayAttendance == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl)
                                  : null,
                              child: user?.photoUrl == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, ${user?.name ?? 'User'}!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    company?.name ?? 'PT Example',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'EEEE, d MMMM y',
                                      'id_ID',
                                    ).format(DateTime.now()),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Real-time Clock with Zone Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currentTime,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedZone,
                              items: const [
                                DropdownMenuItem(
                                  value: 'WIB',
                                  child: Text('WIB'),
                                ),
                                DropdownMenuItem(
                                  value: 'WITA',
                                  child: Text('WITA'),
                                ),
                                DropdownMenuItem(
                                  value: 'WIT',
                                  child: Text('WIT'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedZone = value;
                                    _updateTime();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Attendance Status Card
                Card(
                  elevation: 2,
                  color: todayAttendance != null
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              todayAttendance != null
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              color: todayAttendance != null
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Absensi Hari Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: todayAttendance != null
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (todayAttendance != null) ...[
                          _buildAttendanceInfo(
                            'Clock In',
                            DateFormat(
                              'HH:mm',
                              'id_ID',
                            ).format(todayAttendance.clockIn),
                            Icons.login,
                          ),
                          if (todayAttendance.clockOut != null) ...[
                            const SizedBox(height: 8),
                            _buildAttendanceInfo(
                              'Clock Out',
                              DateFormat(
                                'HH:mm',
                                'id_ID',
                              ).format(todayAttendance.clockOut!),
                              Icons.logout,
                            ),
                            const SizedBox(height: 8),
                            _buildAttendanceInfo(
                              'Durasi',
                              todayAttendance.formattedDuration,
                              Icons.timer,
                            ),
                          ],
                        ] else
                          const Text(
                            'Anda belum melakukan absensi hari ini',
                            style: TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: todayAttendance == null
                            ? Icons.login
                            : todayAttendance.clockOut == null
                            ? Icons.logout
                            : Icons.check_circle,
                        label: todayAttendance == null
                            ? 'Clock In'
                            : todayAttendance.clockOut == null
                            ? 'Clock Out'
                            : 'Selesai',
                        color: todayAttendance == null
                            ? Colors.green
                            : todayAttendance.clockOut == null
                            ? Colors.orange
                            : Colors.grey,
                        onTap: () {
                          if (todayAttendance == null ||
                              todayAttendance.clockOut == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ClockInScreen(),
                              ),
                            ).then((_) => _loadData());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.history,
                        label: 'Riwayat',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.event_note,
                        label: 'Izin/Cuti',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LeaveRequestListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.person,
                        label: 'Profil',
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
