import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'clock_in_screen.dart';
import 'attendance_history_screen.dart';
import 'package:eak_flutter/screens/leave_request_list_screen.dart';
import 'profile_screen.dart';
import 'clock_out_screen.dart';
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

                              // Action Buttons Grid
                              _buildActionGrid(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Floating Clock In Button
            Positioned(
              right: 25,
              bottom: 20,
              child: _buildFloatingClockInButton(),
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
                      color: Colors.white.withOpacity(0.2),
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
      // height: 324,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF80CE70), Color(0xFF26667F)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withOpacity(0.3),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                        color: Colors.white.withOpacity(0.5),
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
                        'Halo, ${user?.name ?? 'Budi Santoso'}!',
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
                        company?.name ?? 'PT Teknologi Maju Bersama',
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
                    color: Colors.white.withOpacity(0.3),
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
                          color: const Color(0xFFE5E7EB).withOpacity(0.5),
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
        ? todayAttendance.formattedDuration
        : '--';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withOpacity(0.4),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                    color: const Color(0xFF26667F).withOpacity(0.1),
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
                        color: const Color(0xFF181F3E).withOpacity(0.7),
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
                        color: const Color(0xFF181F3E).withOpacity(0.7),
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
                  color: const Color(0xFFE5E7EB).withOpacity(0.3),
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
                        color: const Color(0xFF181F3E).withOpacity(0.7),
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
                onTap: () {
                  // TODO: Navigate to Quick Stats
                },
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
                      builder: (context) => LeaveRequestListScreen(),
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
                onTap: () {
                  // TODO: Navigate to Settings
                },
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
            color: const Color(0xFFE5E7EB).withOpacity(0.3),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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

  Widget _buildFloatingClockInButton() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final todayAttendance = attendanceProvider.todayAttendance;

        return GestureDetector(
          onTap: () {
            if (todayAttendance == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClockInScreen()),
              ).then((_) => _loadData());
            } else if (todayAttendance.clockOut == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClockOutScreen()),
              ).then((_) => _loadData());
            }
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF26667F).withOpacity(0.56),
                  const Color(0xFF26667F),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 32),
                const SizedBox(height: 3),
                Text(
                  todayAttendance == null
                      ? 'Clock In'
                      : todayAttendance.clockOut == null
                      ? 'Clock Out'
                      : 'Done',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
