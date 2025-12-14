import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/leave_request_provider.dart';
import '../models/leave_request_model.dart';
import '../config/api_config.dart';
import 'attendance_history_screen.dart';
import 'package:eak_flutter/screens/leave_request_list_screen.dart';
import 'package:eak_flutter/screens/clock_in_screen.dart';
import 'package:eak_flutter/screens/clock_out_screen.dart';
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
  int _bottomTabIndex = 0; // 0 = Attendance, 1 = My Leaves, 2 = Notifications

  @override
  void initState() {
    super.initState();
    _startClock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
    final leaveProvider = Provider.of<LeaveRequestProvider>(context, listen: false);
    await leaveProvider.loadLeaveRequests();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
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
        body: SafeArea(
          child: Consumer2<AuthProvider, AttendanceProvider>(
            builder: (context, authProvider, attendanceProvider, child) {
              final user = authProvider.user;
              final company = authProvider.company;
              final todayAttendance = attendanceProvider.todayAttendance;

              if (attendanceProvider.isLoading && todayAttendance == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  _buildTopHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          _buildMainClockCard(
                            user: user,
                            company: company,
                            todayAttendance: todayAttendance,
                          ),
                          const SizedBox(height: 24),
                          _buildBottomTabs(),
                          const SizedBox(height: 16),
                          if (_bottomTabIndex == 0)
                            _buildAttendanceSection(todayAttendance)
                          else if (_bottomTabIndex == 1)
                            _buildMyLeavesSection()
                          else
                            _buildNotificationsSection(),
                          const SizedBox(height: 24),
                          _buildQuickActionsRow(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------- HEADER ATAS (kecil) ----------

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF80CE70), Color(0xFF26667F)], // hijau–biru
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/icon_login.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ClockIn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          InkWell(
            key: const Key('profile_button'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- KARTU TENGAH UTAMA ----------

  Widget _buildMainClockCard({
    required dynamic user,
    required dynamic company,
    required dynamic todayAttendance,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: (user?.photoUrl != null && user!.photoUrl.isNotEmpty)
                      ? NetworkImage(user!.photoUrl)
                      : null,
                  child: (user?.photoUrl == null || user!.photoUrl.isEmpty)
                      ? const Icon(Icons.person, size: 26)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF181F3E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      company?.name ?? 'PT. Example',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
            style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 20),

          // Tombol bulat besar
          GestureDetector(
            onTap: () async {
              if (todayAttendance?.clockIn == null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClockInScreen()),
                );
                _loadData(); // Refresh data after returning
              } else if (todayAttendance?.clockOut == null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClockOutScreen()),
                );
                _loadData();
              }
            },
            child: Container(
              width: 210,
              height: 210,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF80CE70), Color(0xFF26667F)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3380CE70),
                    blurRadius: 26,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.65),
                    width: 7,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 44, // angka jam lebih besar
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      todayAttendance?.clockIn == null
                          ? 'Tap to Clock In'
                          : (todayAttendance.clockOut == null
                                ? 'Tap to Clock Out'
                                : 'Attendance Complete'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 3 info kecil di bawah tombol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _smallInfoChip(
                title: 'Clock In',
                value: todayAttendance?.clockIn != null
                    ? DateFormat('HH:mm').format(todayAttendance.clockIn)
                    : '--:--',
              ),
              _smallInfoChip(
                title: 'Clock Out',
                value: todayAttendance?.clockOut != null
                    ? DateFormat('HH:mm').format(todayAttendance.clockOut!)
                    : '--:--',
              ),
              _smallInfoChip(
                title: 'Durasi',
                value: todayAttendance?.clockOut != null
                    ? todayAttendance.formattedWorkDuration
                    : '--',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallInfoChip({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181F3E),
          ),
        ),
      ],
    );
  }

  // ---------- TAB BAWAH (Attendance / My Leaves / Notifications) ----------

  Widget _buildBottomTabs() {
    final labels = ['Attendance', 'My Leaves', 'Notifications'];
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == _bottomTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _bottomTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF26667F)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------- SECTION: ATTENDANCE LIST ----------

  Widget _buildAttendanceSection(dynamic todayAttendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassCard(
          title: 'Today Attendance',
          icon: Icons.access_time,
          iconColor: const Color(0xFF26667F),
          child: Column(
            children: [
              _infoRow(
                'Clock In',
                todayAttendance?.clockIn != null
                    ? DateFormat('HH:mm').format(todayAttendance.clockIn)
                    : '--:--',
              ),
              const SizedBox(height: 6),
              _infoRow(
                'Clock Out',
                todayAttendance?.clockOut != null
                    ? DateFormat('HH:mm').format(todayAttendance.clockOut!)
                    : '--:--',
              ),
              const SizedBox(height: 6),
              _infoRow(
                'Durasi',
                todayAttendance?.clockOut != null
                    ? todayAttendance.formattedWorkDuration
                    : '--',
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF26667F),
                  ),
                  label: const Text(
                    'View History',
                    style: TextStyle(
                      color: Color(0xFF26667F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF181F3E).withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181F3E),
          ),
        ),
      ],
    );
  }

  // ---------- SECTION: MY LEAVES (pakai data _leaveRequests) ----------

  Widget _buildMyLeavesSection() {
    return Consumer<LeaveRequestProvider>(
      builder: (context, provider, child) {
        final leaveRequests = provider.leaveRequests;
        
        return _buildGlassCard(
          title: 'My Leaves',
          icon: Icons.beach_access_outlined,
          iconColor: const Color(0xFFFFA726),
          child: leaveRequests.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 42,
                        color: const Color(0xFF9CA3AF).withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No leave requests yet',
                        style: TextStyle(fontSize: 13.5, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    ...leaveRequests
                        .take(4)
                        .map((r) => _buildLeaveRequestItem(r))
                        .toList(),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaveRequestListScreen(),
                            ),
                          ).then((_) => _loadLeaveRequests());
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFF26667F),
                        ),
                        label: const Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF26667F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.4),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF181F3E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- LEAVE ITEM ----------

  Widget _buildLeaveRequestItem(LeaveRequest request) {
    // Model usage
    final status = request.status;
    final type = request.jenis;
    // startDate is String in Model? Let's check model again. 
    // Model says String startDate. UI needs DateTime.
    // I will parse it.
    final startDate = DateTime.tryParse(request.startDate) ?? DateTime.now();

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

    String typeLabel;
    IconData typeIcon;
    switch (type.toLowerCase()) {
      case 'sick':
      case 'sakit': // Add Bahasa support just in case
        typeLabel = 'Sick Leave';
        typeIcon = Icons.local_hospital_outlined;
        break;
      case 'annual':
      case 'cuti': // Add Bahasa support
        typeLabel = 'Annual Leave';
        typeIcon = Icons.beach_access_outlined;
        break;
      case 'permission':
      case 'izin':
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181F3E),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(startDate),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
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

  // ---------- SECTION: NOTIFICATIONS (dummy, pakai style mirip) ----------

  Widget _buildNotificationsSection() {
    // Sementara pakai data leave sebagai notifikasi contoh
    return Consumer<LeaveRequestProvider>(
      builder: (context, provider, child) {
        final items = provider.leaveRequests.take(5).toList();
        return _buildGlassCard(
          title: 'Notifications',
          icon: Icons.notifications_none,
          iconColor: const Color(0xFF26667F),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 42,
                        color: const Color(0xFF9CA3AF).withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No notifications yet',
                        style: TextStyle(fontSize: 13.5, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: items
                      .map(
                        (r) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(
                              0xFF26667F,
                            ).withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.mail_outline,
                              color: Color(0xFF26667F),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Leave ${r.status}', // Model usage
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Type: ${r.jenis}', // Model usage (jenis)
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }

  // ---------- QUICK ACTIONS ----------

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            icon: Icons.bar_chart,
            label: 'Quick Stats',
            color: const Color(0xFF80CE70),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _quickActionButton(
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
        const SizedBox(width: 16),
        Expanded(
          child: _quickActionButton(
            icon: Icons.note_alt_outlined,
            label: 'Leave',
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
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E7EB).withValues(alpha: 0.4),
            width: 0.7,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181F3E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
