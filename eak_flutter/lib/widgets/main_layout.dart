import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/attendance_history_screen.dart';
import '../screens/leave_request_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/clock_in_screen.dart';
import '../screens/clock_out_screen.dart';
import '../providers/attendance_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const MainLayout({super.key, required this.child, this.selectedIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onNavItemTapped(int index) async {
    // Handle Clock In/Out button (index 2)
    if (index == 2) {
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      final todayAttendance = attendanceProvider.todayAttendance;

      // If no attendance today, navigate to Clock In
      if (todayAttendance == null) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClockInScreen()),
        );

        // ✅ REFRESH setelah kembali dari Clock In
        if (mounted) {
          await attendanceProvider.loadTodayAttendance();
          setState(() {}); // ← PENTING! Force rebuild
        }
      }
      // If clocked in but not clocked out, navigate to Clock Out
      else if (todayAttendance.clockOut == null) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClockOutScreen()),
        );

        // ✅ REFRESH setelah kembali dari Clock Out
        if (mounted) {
          await attendanceProvider.loadTodayAttendance();
          setState(() {}); // ← PENTING! Force rebuild
        }
      }
      // If already clocked out, do nothing
      else {
        return;
      }

      return;
    }

    if (index == widget.selectedIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const AttendanceHistoryScreen();
        break;
      case 3:
        destination = const LeaveRequestListScreen();
        break;
      case 4:
        destination = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    // ✅ WRAP DENGAN CONSUMER untuk auto-rebuild
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final todayAttendance = attendanceProvider.todayAttendance;

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE5E7EB).withOpacity(0.5),
                width: 0.6,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: widget.selectedIndex == 0,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.history,
                    label: 'History',
                    index: 1,
                    isSelected: widget.selectedIndex == 1,
                  ),
                ),
                Expanded(child: _buildClockButton(todayAttendance)),
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.note_alt_outlined,
                    label: 'Leave',
                    index: 3,
                    isSelected: widget.selectedIndex == 3,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    index: 4,
                    isSelected: widget.selectedIndex == 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClockButton(dynamic todayAttendance) {
    bool isClockOut =
        todayAttendance != null && todayAttendance.clockOut == null;
    bool isDone = todayAttendance != null && todayAttendance.clockOut != null;

    Color gradientStart;
    Color gradientEnd;
    String label;
    IconData icon;

    if (isDone) {
      gradientStart = Colors.grey.withOpacity(0.56);
      gradientEnd = Colors.grey;
      label = 'Done';
      icon = Icons.check;
    } else if (isClockOut) {
      gradientStart = const Color(0xFFE57373);
      gradientEnd = const Color(0xFFD32F2F);
      label = 'Out';
      icon = Icons.logout;
    } else {
      gradientStart = const Color(0xFF80CE70);
      gradientEnd = const Color(0xFF26667F);
      label = 'In';
      icon = Icons.login;
    }

    return GestureDetector(
      onTap: isDone ? null : () => _onNavItemTapped(2),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientStart, gradientEnd],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradientEnd.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF26667F),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            SizedBox(height: isSelected ? 4 : 7),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF26667F) : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF26667F) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}