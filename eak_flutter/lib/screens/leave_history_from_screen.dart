import 'package:eak_flutter/screens/leave_request_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/leave_request_provider.dart';
import '../models/leave_request_model.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  String? _selectedStatus;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<LeaveRequestProvider>(context, listen: false);
    await provider.loadLeaveRequests(page: 1, status: _selectedStatus);
    _currentPage = 1;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final provider = Provider.of<LeaveRequestProvider>(context, listen: false);
    await provider.loadLeaveRequests(
      page: _currentPage + 1,
      status: _selectedStatus,
    );

    setState(() {
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  void _showFilterDialog() async {
    String? tempStatus = _selectedStatus;

    await showDialog(
      context: context,
      builder: (context) {
        String? dialogStatus = tempStatus;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Filter Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Semua'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: dialogStatus,
                    onChanged: (value) =>
                        setDialogState(() => dialogStatus = value),
                  ),
                  onTap: () => setDialogState(() => dialogStatus = null),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('Pending'),
                  leading: Radio<String?>(
                    value: 'pending',
                    groupValue: dialogStatus,
                    onChanged: (value) =>
                        setDialogState(() => dialogStatus = value),
                  ),
                  onTap: () => setDialogState(() => dialogStatus = 'pending'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('Approved'),
                  leading: Radio<String?>(
                    value: 'approved',
                    groupValue: dialogStatus,
                    onChanged: (value) =>
                        setDialogState(() => dialogStatus = value),
                  ),
                  onTap: () => setDialogState(() => dialogStatus = 'approved'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('Rejected'),
                  leading: Radio<String?>(
                    value: 'rejected',
                    groupValue: dialogStatus,
                    onChanged: (value) =>
                        setDialogState(() => dialogStatus = value),
                  ),
                  onTap: () => setDialogState(() => dialogStatus = 'rejected'),
                  contentPadding: EdgeInsets.zero,
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
                  setState(() => _selectedStatus = dialogStatus);
                  _loadData();
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Leave History",
          style: TextStyle(
            color: Color(0xFF181F3E),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF181F3E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<LeaveRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.leaveRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.leaveRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat izin',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: provider.leaveRequests.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.leaveRequests.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: _isLoadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : TextButton(
                            onPressed: _loadMore,
                            child: const Text('Muat lebih banyak'),
                          ),
                  );
                }

                final leave = provider.leaveRequests[index];
                return _buildLeaveCard(leave);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaveRequestListScreen(),
            ),
          );

          if (result != null && result['success'] == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Berhasil!'),
                backgroundColor: const Color(0xFF80CE70),
                duration: const Duration(seconds: 3),
              ),
            );
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Izin'),
        backgroundColor: const Color(0xFF26667F),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave) {
    final statusColor = _getStatusColor(leave.status);
    final statusLabel = _getStatusLabel(leave.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar status kecil di atas
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),

            // Header: icon + type + status pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTypeIcon(leave.jenis),
                        size: 20,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeLabel(leave.jenis),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF181F3E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat(
                                'd MMM yyyy',
                              ).format(DateTime.parse(leave.startDate)) +
                              (leave.endDate != leave.startDate
                                  ? ' - ${DateFormat('d MMM yyyy').format(DateTime.parse(leave.endDate))}'
                                  : ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_outlined,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leave.reason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (leave.attachment != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Color(0xFF26667F),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Ada lampiran',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF26667F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- HELPER: STATUS & TYPE ---

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return Icons.local_hospital;
      case 'annual':
        return Icons.beach_access;
      case 'permission':
        return Icons.event;
      case 'emergency':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return 'Sakit';
      case 'annual':
        return 'Cuti Tahunan';
      case 'permission':
        return 'Izin';
      case 'emergency':
        return 'Darurat';
      default:
        return type;
    }
  }
}
