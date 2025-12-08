import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../screens/home_screen.dart';
import '../screens/attendance_history_screen.dart';
import '../screens/leave_request_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/clock_in_screen.dart';
import '../screens/clock_out_screen.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: _buildFloatingClockInButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home
              _buildNavItem(
                context: context,
                icon: Icons.home,
                label: 'Home',
                index: 0,
                onTap: () => _navigateTo(context, 0),
              ),

              // History
              _buildNavItem(
                context: context,
                icon: Icons.access_time,
                label: 'History',
                index: 1,
                onTap: () => _navigateTo(context, 1),
              ),

              // SPACER untuk Clock In Button di tengah
              const SizedBox(width: 60),

              // Leave Request
              _buildNavItem(
                context: context,
                icon: Icons.note_alt_outlined,
                label: 'Leave',
                index: 2,
                onTap: () => _navigateTo(context, 2),
              ),

              // Profile
              _buildNavItem(
                context: context,
                icon: Icons.person,
                label: 'Profile',
                index: 3,
                onTap: () => _navigateTo(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF26667F) : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF26667F) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingClockInButton(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final todayAttendance = attendanceProvider.todayAttendance;

        final IconData icon;
        final Color bgColor;
        final Widget targetScreen;

        if (todayAttendance == null) {
          // Belum clock in hari ini
          icon = Icons.login;
          bgColor = const Color(0xFF80CE70); // Hijau
          targetScreen = const ClockInScreen();
        } else if (todayAttendance.clockOut == null) {
          // Sudah clock in, belum clock out
          icon = Icons.logout;
          bgColor = Colors.orange; // Orange
          targetScreen = const ClockOutScreen();
        } else {
          // Sudah clock in DAN clock out
          icon = Icons.check;
          bgColor = Colors.grey; // Abu-abu (disabled)
          targetScreen = const HomeScreen(); // Dummy, tidak akan dipanggil
        }

        return FloatingActionButton(
          onPressed: todayAttendance?.clockOut != null
              ? null // ✅ Disable jika sudah clock out
              : () async {
                  // ✅ Navigate ke screen yang sesuai
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => targetScreen),
                  );

                  // ✅ Reload attendance SETELAH kembali dari screen
                  if (context.mounted && result != false) {
                    await attendanceProvider.loadTodayAttendance();
                  }
                },
          backgroundColor: bgColor,
          elevation: 8,
          child: Icon(icon, color: Colors.white, size: 30),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, int index) {
    if (selectedIndex == index) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const AttendanceHistoryScreen();
        break;
      case 2:
        screen = const LeaveRequestListScreen();
        break;
      case 3:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
