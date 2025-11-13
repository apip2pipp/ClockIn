import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/leave_request_provider.dart';
import '../models/leave_request_model.dart';
import 'leave_request_form_screen.dart';

class LeaveRequestListScreen extends StatefulWidget {
  const LeaveRequestListScreen({super.key});

  @override
  State<LeaveRequestListScreen> createState() => _LeaveRequestListScreenState();
}

class _LeaveRequestListScreenState extends State<LeaveRequestListScreen> {
  String? _selectedStatus;
  String? _selectedType;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final leaveProvider = Provider.of<LeaveRequestProvider>(
      context,
      listen: false,
    );
    await leaveProvider.loadLeaveRequests(
      page: 1,
      status: _selectedStatus,
      type: _selectedType,
    );
    _currentPage = 1;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final leaveProvider = Provider.of<LeaveRequestProvider>(
      context,
      listen: false,
    );
    await leaveProvider.loadLeaveRequests(
      page: _currentPage + 1,
      status: _selectedStatus,
      type: _selectedType,
    );

    setState(() {
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  Future<void> _showFilterDialog() async {
    String? tempStatus = _selectedStatus;
    String? tempType = _selectedType;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Pengajuan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Filter
              DropdownButtonFormField<String?>(
                initialValue: tempStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Semua Status')),
                  DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
                  DropdownMenuItem(value: 'approved', child: Text('Disetujui')),
                  DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                ],
                onChanged: (value) {
                  setState(() {
                    tempStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Type Filter
              DropdownButtonFormField<String?>(
                initialValue: tempType,
                decoration: const InputDecoration(
                  labelText: 'Jenis',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Semua Jenis')),
                  DropdownMenuItem(value: 'sick', child: Text('Sakit')),
                  DropdownMenuItem(
                    value: 'annual',
                    child: Text('Cuti Tahunan'),
                  ),
                  DropdownMenuItem(value: 'permission', child: Text('Izin')),
                  DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                ],
                onChanged: (value) {
                  setState(() {
                    tempType = value;
                  });
                },
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
                this.setState(() {
                  _selectedStatus = tempStatus;
                  _selectedType = tempType;
                });
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
        title: const Text('Izin & Cuti'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<LeaveRequestProvider>(
        builder: (context, leaveProvider, child) {
          if (leaveProvider.isLoading && leaveProvider.leaveRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (leaveProvider.leaveRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengajuan',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaveRequestFormScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajukan Izin/Cuti'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaveProvider.leaveRequests.length + 1,
              itemBuilder: (context, index) {
                if (index == leaveProvider.leaveRequests.length) {
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

                final leave = leaveProvider.leaveRequests[index];
                return _buildLeaveCard(leave);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaveRequestFormScreen(),
            ),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
        backgroundColor: Theme.of(context).primaryColor,
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
            // Type and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    leave.typeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(leave.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    leave.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
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
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('d MMM y', 'id_ID').format(leave.startDate)} - ${DateFormat('d MMM y', 'id_ID').format(leave.endDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Total Days
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${leave.totalDays} hari',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reason
            const Text(
              'Alasan:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              leave.reason,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Rejection Reason (if rejected)
            if (leave.status == 'rejected' &&
                leave.rejectionReason != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                'Alasan Ditolak:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                leave.rejectionReason!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],

            // Attachment indicator
            if (leave.attachment != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Dengan lampiran',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],

            // Submission date
            const SizedBox(height: 8),
            Text(
              'Diajukan: ${DateFormat('d MMM y HH:mm', 'id_ID').format(leave.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
