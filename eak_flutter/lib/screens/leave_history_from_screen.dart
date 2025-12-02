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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                title: const Text('Semua'),
                value: null,
                groupValue: tempStatus,
                onChanged: (value) => setState(() => tempStatus = value),
              ),
              RadioListTile<String?>(
                title: const Text('Pending'),
                value: 'pending',
                groupValue: tempStatus,
                onChanged: (value) => setState(() => tempStatus = value),
              ),
              RadioListTile<String?>(
                title: const Text('Approved'),
                value: 'approved',
                groupValue: tempStatus,
                onChanged: (value) => setState(() => tempStatus = value),
              ),
              RadioListTile<String?>(
                title: const Text('Rejected'),
                value: 'rejected',
                groupValue: tempStatus,
                onChanged: (value) => setState(() => tempStatus = value),
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
                setState(() => _selectedStatus = tempStatus);
                _loadData();
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Izin"),
        backgroundColor: Colors.blue,
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
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
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
              padding: const EdgeInsets.all(16),
              itemCount: provider.leaveRequests.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.leaveRequests.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isLoadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : TextButton(
                            onPressed: _loadMore,
                            child: const Text('Muat Lebih Banyak'),
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
          // ✅ AWAIT RESULT DARI FORM
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaveRequestListScreen(),
            ),
          );

          if (result != null && result['success'] == true && mounted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Berhasil!'),
                backgroundColor: Colors.green, // ✅ HIJAU!
                duration: const Duration(seconds: 3),
              ),
            );

            // ✅ REFRESH LIST
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Izin'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getTypeIcon(leave.jenis), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeLabel(leave.jenis),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(leave.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(leave.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStatusColor(leave.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('d MMM yyyy').format(DateTime.parse(leave.startDate))} - ${DateFormat('d MMM yyyy').format(DateTime.parse(leave.endDate))}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leave.reason,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Attachment indicator
            if (leave.attachment != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 14, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Ada lampiran',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
}
