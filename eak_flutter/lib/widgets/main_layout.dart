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
      extendBody: true,
      body: child,
      bottomNavigationBar: _ModernBottomNavBar(selectedIndex: selectedIndex),
    );
  }
}

class _ModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const _ModernBottomNavBar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, _) {
        final todayAttendance = attendanceProvider.todayAttendance;

        final bool canClockIn = todayAttendance == null;
        final bool canClockOut =
            todayAttendance != null && todayAttendance.clockOut == null;
        final bool doneToday =
            todayAttendance != null && todayAttendance.clockOut != null;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: () => _navigateTo(context, 0),
                ),
                _NavItem(
                  icon: Icons.access_time,
                  label: 'History',
                  index: 1,
                  selectedIndex: selectedIndex,
                  onTap: () => _navigateTo(context, 1),
                ),

                // Tombol tengah (Clock In/Out) mirip referensi
                GestureDetector(
                  onTap: doneToday
                      ? null
                      : () async {
                          Widget target;
                          if (canClockIn) {
                            target = const ClockInScreen();
                          } else if (canClockOut) {
                            target = const ClockOutScreen();
                          } else {
                            return;
                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => target),
                          );

                          if (context.mounted && result != false) {
                            await attendanceProvider.loadTodayAttendance();
                          }
                        },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF80CE70), // hijau
                          Color(0xFF26667F), // biru
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF26667F,
                          ).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      doneToday
                          ? Icons.check
                          : (canClockIn ? Icons.login : Icons.logout),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                _NavItem(
                  icon: Icons.note_alt_outlined,
                  label: 'Leave',
                  index: 2,
                  selectedIndex: selectedIndex,
                  onTap: () => _navigateTo(context, 2),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 3,
                  selectedIndex: selectedIndex,
                  onTap: () => _navigateTo(context, 3),
                ),
              ],
            ),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF26667F)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF26667F)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
