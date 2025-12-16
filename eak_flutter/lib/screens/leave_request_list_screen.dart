import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/leave_request_provider.dart';
import '../widgets/main_layout.dart';

class LeaveRequestListScreen extends StatefulWidget {
  const LeaveRequestListScreen({super.key});

  @override
  State<LeaveRequestListScreen> createState() => _LeaveRequestListScreenState();
}

class _LeaveRequestListScreenState extends State<LeaveRequestListScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _jenis;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  File? _attachment;
  bool _isSubmitting = false;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal mulai terlebih dahulu")),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jenis izin terlebih dahulu")),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tanggal cuti harus diisi")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = Provider.of<LeaveRequestProvider>(
        context,
        listen: false,
      );

      final success = await provider.submitLeaveRequest(
        type: _jenis!,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        attachment: _attachment,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan izin berhasil! ✅'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true untuk refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Gagal mengajukan izin'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with gradient
              _buildHeader(context),

              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB).withValues(alpha: 0.4),
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
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                const Center(
                                  child: Text(
                                    "Form Pengajuan Izin & Cuti",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF181F3E),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // JENIS CUTI
                                _buildField(
                                  label: "Jenis Izin",
                                  icon: Icons.category,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _jenis,
                                      hint: const Text("Pilih jenis izin"),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: "sick",
                                          child: Text("Sakit"),
                                        ),
                                        DropdownMenuItem(
                                          value: "annual",
                                          child: Text("Cuti Tahunan"),
                                        ),
                                        DropdownMenuItem(
                                          value: "permission",
                                          child: Text("Izin"),
                                        ),
                                        DropdownMenuItem(
                                          value: "other",
                                          child: Text("Lainnya"),
                                        ),
                                      ],
                                      onChanged: (val) =>
                                          setState(() => _jenis = val),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // TANGGAL MULAI
                                _buildField(
                                  label: "Tanggal Mulai",
                                  icon: Icons.calendar_month,
                                  child: InkWell(
                                    onTap: _pickStartDate,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        _startDate == null
                                            ? "Pilih tanggal"
                                            : DateFormat(
                                                'd MMMM yyyy',
                                                'id_ID',
                                              ).format(_startDate!),
                                        style: TextStyle(
                                          color: _startDate == null
                                              ? Colors.grey[500]
                                              : const Color(0xFF181F3E),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // TANGGAL SELESAI
                                _buildField(
                                  label: "Tanggal Selesai",
                                  icon: Icons.calendar_today,
                                  child: InkWell(
                                    onTap: _pickEndDate,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        _endDate == null
                                            ? "Pilih tanggal"
                                            : DateFormat(
                                                'd MMMM yyyy',
                                                'id_ID',
                                              ).format(_endDate!),
                                        style: TextStyle(
                                          color: _endDate == null
                                              ? Colors.grey[500]
                                              : const Color(0xFF181F3E),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ALASAN
                                _buildField(
                                  label: "Alasan",
                                  icon: Icons.edit_note,
                                  child: TextFormField(
                                    controller: _reasonController,
                                    maxLines: 4,
                                    style: const TextStyle(fontSize: 15),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Tulis alasan izin / cuti",
                                      hintStyle: TextStyle(fontSize: 15),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? "Wajib diisi"
                                        : null,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ATTACHMENT
                                _buildField(
                                  label: "Lampiran (Opsional)",
                                  icon: Icons.attach_file,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _attachment != null
                                              ? _attachment!.path
                                                    .split('/')
                                                    .last
                                              : "Belum ada file",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: _attachment != null
                                                ? const Color(0xFF181F3E)
                                                : Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _pickAttachment,
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF26667F,
                                          ),
                                        ),
                                        child: const Text(
                                          "Pilih File",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 35),

                                // SUBMIT BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      backgroundColor: const Color(0xFF26667F),
                                      disabledBackgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            "KIRIM PENGAJUAN",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                      'Izin & Cuti',
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181F3E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF26667F).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF26667F), size: 22),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}
