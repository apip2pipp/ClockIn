import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../config/api_config.dart';
import 'attendance_history_screen.dart';
import 'package:eak_flutter/screens/leave_request_list_screen.dart';
import 'profile_screen.dart';
import '../widgets/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  String _currentTime = '';
  String _selectedZone = 'WIB';
  List<Map<String, dynamic>> _leaveRequests = [];

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
    await _loadLeaveRequests();
  }

  Future<void> _loadLeaveRequests() async {
    try {
      final token = await AuthProvider.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.leaveUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final leaveRequests = data['leave_requests'] as List;

        setState(() {
          _leaveRequests = leaveRequests
              .take(3)
              .map((req) => req as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading leave requests: $e');
    }
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    DateTime now = DateTime.now();

    switch (_selectedZone) {
      case 'WITA':
        now = now.add(const Duration(hours: 1));
        break;
      case 'WIT':
        now = now.add(const Duration(hours: 2));
        break;
      default:
        break;
    }

    setState(() {
      _currentTime = DateFormat('HH:mm').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            // Main Content
            SafeArea(
              child: Consumer2<AuthProvider, AttendanceProvider>(
                builder: (context, authProvider, attendanceProvider, child) {
                  final user = authProvider.user;
                  final company = authProvider.company;
                  final todayAttendance = attendanceProvider.todayAttendance;

                  if (attendanceProvider.isLoading && todayAttendance == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return CustomScrollView(
                    slivers: [
                      // Header with ClockIn logo and profile button
                      _buildHeader(context),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              // Gradient Card with User Info and Clock
                              _buildGradientCard(
                                user,
                                company,
                                todayAttendance,
                              ),

                              const SizedBox(height: 30),

                              // Attendance Status Card
                              _buildAttendanceCard(todayAttendance),

                              const SizedBox(height: 30),

                              // Leave Requests Card
                              _buildLeaveRequestsCard(),

                              const SizedBox(height: 30),

                              // Action Buttons Grid
                              _buildActionGrid(),

                              const SizedBox(
                                height: 100,
                              ), // Space for floating button
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF80CE70), Color(0xFF26667F)],
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
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
                      'ClockIn',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Profile Button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
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

  Widget _buildGradientCard(user, company, todayAttendance) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF80CE70), Color(0xFF26667F)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.3),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${user?.name ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 22.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF181F3E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company?.name ?? 'PT. Example',
                        style: const TextStyle(
                          fontSize: 17.5,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date
            Text(
              DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),

            const SizedBox(height: 12),

            // Clock Circle
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Timezone Selector
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedZone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 15,
                                color: Colors.grey[700],
                              ),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                setState(() {
                                  _selectedZone = value;
                                  _updateTime();
                                });
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'WIB',
                                  child: Text('WIB'),
                                ),
                                const PopupMenuItem(
                                  value: 'WITA',
                                  child: Text('WITA'),
                                ),
                                const PopupMenuItem(
                                  value: 'WIT',
                                  child: Text('WIT'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(todayAttendance) {
    final clockInTime = todayAttendance != null
        ? DateFormat('HH:mm').format(todayAttendance.clockIn)
        : '--:--';
    final clockOutTime = todayAttendance?.clockOut != null
        ? DateFormat('HH:mm').format(todayAttendance.clockOut!)
        : '--:--';
    final duration = todayAttendance?.clockOut != null
        ? todayAttendance.formattedWorkDuration
        : '--';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.4),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26667F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Color(0xFF26667F),
                    size: 30,
                  ),
                ),

                const SizedBox(height: 20),

                // Clock In
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clock In:',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF181F3E).withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      clockInTime,
                      style: const TextStyle(
                        fontSize: 22.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF181F3E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Clock Out
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clock Out:',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF181F3E).withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      clockOutTime,
                      style: const TextStyle(
                        fontSize: 22.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF181F3E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                Divider(
                  color: const Color(0xFFE5E7EB).withValues(alpha: 0.3),
                  thickness: 0.6,
                ),

                const SizedBox(height: 15),

                // Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Durasi:',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF181F3E).withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 22.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF124170),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.4),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFA726,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.note_alt_outlined,
                              color: Color(0xFFFFA726),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Text(
                              'Leave Requests',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF181F3E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 22),
                      color: const Color(0xFF26667F),
                      onPressed: _loadLeaveRequests,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _leaveRequests.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: const Color(
                                  0xFF6B7280,
                                ).withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No leave requests yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(
                                    0xFF6B7280,
                                  ).withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _leaveRequests
                            .map((request) => _buildLeaveRequestItem(request))
                            .toList(),
                      ),
                if (_leaveRequests.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LeaveRequestListScreen(),
                          ),
                        ).then((_) => _loadLeaveRequests());
                      },
                      icon: const Icon(
                        Icons.list_alt,
                        size: 18,
                        color: Color(0xFF26667F),
                      ),
                      label: const Text(
                        'View All Leave Requests',
                        style: TextStyle(
                          color: Color(0xFF26667F),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestItem(Map<String, dynamic> request) {
    final status = request['status'] as String? ?? 'pending';
    final type = request['type'] as String? ?? 'unknown';
    final startDate = request['start_date'] != null
        ? DateTime.parse(request['start_date'])
        : DateTime.now();

    // Status colors and labels
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF80CE70);
        statusLabel = 'Approved';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = const Color(0xFFE57373);
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFFFA726);
        statusLabel = 'Pending';
        statusIcon = Icons.schedule;
    }

    // Type labels
    String typeLabel;
    IconData typeIcon;

    switch (type.toLowerCase()) {
      case 'sick':
        typeLabel = 'Sick Leave';
        typeIcon = Icons.local_hospital_outlined;
        break;
      case 'annual':
        typeLabel = 'Annual Leave';
        typeIcon = Icons.beach_access_outlined;
        break;
      case 'permission':
        typeLabel = 'Permission';
        typeIcon = Icons.edit_calendar_outlined;
        break;
      case 'emergency':
        typeLabel = 'Emergency Leave';
        typeIcon = Icons.warning_amber_outlined;
        break;
      default:
        typeLabel = type;
        typeIcon = Icons.event_note;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: statusColor, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181F3E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(startDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.bar_chart,
                label: 'Quick Stats',
                color: const Color(0xFF80CE70),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionButton(
                icon: Icons.calendar_today,
                label: 'History',
                color: const Color(0xFF26667F),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.note_alt_outlined,
                label: 'Leave Request',
                color: const Color(0xFFFFA726),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeaveRequestListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionButton(
                icon: Icons.settings,
                label: 'Settings',
                color: const Color(0xFF7E57C2),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E7EB).withValues(alpha: 0.3),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181F3E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
