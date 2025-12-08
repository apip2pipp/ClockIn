import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../screens/home_screen.dart';
import '../screens/attendance_history_screen.dart';
import '../screens/leave_request_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/clock_in_screen.dart';

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
            color: Colors.black.withOpacity(0.1),
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
              color: isSelected 
                  ? const Color(0xFF26667F)
                  : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? const Color(0xFF26667F)
                    : Colors.grey,
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

        // BUTTON UI ORIGINAL (BESAR DI TENGAH)
        return FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClockInScreen(),
              ),
            );

            if (context.mounted) {
              await attendanceProvider.loadTodayAttendance();
            }
          },
          backgroundColor: todayAttendance == null
              ? const Color(0xFF26667F) // Hijau kalau belum clock in
              : todayAttendance.clockOut == null
                  ? const Color(0xFFE57373) // Merah kalau sudah clock in, belum clock out
                  : Colors.grey, // Abu kalau sudah clock out
          elevation: 8,
          child: Icon(
            todayAttendance == null
                ? Icons.login // Belum clock in
                : todayAttendance.clockOut == null
                    ? Icons.logout // Sudah clock in
                    : Icons.check, // Sudah clock out
            color: Colors.white,
            size: 30,
          ),
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