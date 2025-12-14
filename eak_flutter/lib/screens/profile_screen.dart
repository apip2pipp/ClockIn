import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../widgets/main_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with gradient
              _buildHeader(context),

              SliverToBoxAdapter(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.user;
                    final company = authProvider.company;

                    return Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          // Profile Header
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(
                                  0xFFE5E7EB,
                                ).withValues(alpha: 0.4),
                                width: 0.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage: (user?.photoUrl != null && user!.photoUrl.isNotEmpty) 
                                            ? NetworkImage(user!.photoUrl)
                                            : null,
                                        child: user?.photoUrl == null
                                            ? const Icon(Icons.person, size: 50)
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        user?.name ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF181F3E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user?.email ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF26667F,
                                          ).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF26667F,
                                            ).withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          user?.role ?? 'employee',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF26667F),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Personal Information
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFFE5E7EB,
                                ).withValues(alpha: 0.4),
                                width: 0.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        color: Color(0xFF26667F),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Informasi Pribadi',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF181F3E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.badge_outlined,
                                  label: 'ID Karyawan',
                                  value: user?.employeeId ?? '-',
                                ),
                                _buildInfoTile(
                                  icon: Icons.work_outline,
                                  label: 'Posisi',
                                  value: user?.position ?? '-',
                                ),
                                _buildInfoTile(
                                  icon: Icons.phone_outlined,
                                  label: 'Telepon',
                                  value: user?.phone ?? '-',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Company Information
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFFE5E7EB,
                                ).withValues(alpha: 0.4),
                                width: 0.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.business_outlined,
                                        color: Color(0xFF80CE70),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Informasi Perusahaan',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF181F3E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.apartment,
                                  label: 'Perusahaan',
                                  value: company?.name ?? '-',
                                ),
                                _buildInfoTile(
                                  icon: Icons.location_on_outlined,
                                  label: 'Alamat',
                                  value: company?.address ?? '-',
                                ),
                                _buildInfoTile(
                                  icon: Icons.access_time,
                                  label: 'Jam Kerja',
                                  value: company != null
                                      ? '${company.workStartTime} - ${company.workEndTime}'
                                      : '-',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Logout Button
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleLogout(context),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
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
                      'Profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 63),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF26667F).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF26667F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            ),
          ),
        ],
      ),
    );
  }
}
