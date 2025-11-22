import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/leave_request_provider.dart';

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

  Widget buildField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[700]),
              const SizedBox(width: 10),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Izin dan Cuti"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Form Pengajuan Izin & Cuti",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                // JENIS CUTI
                buildField(
                  label: "Jenis Izin",
                  icon: Icons.category,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _jenis,
                      hint: const Text("Pilih jenis izin"),
                      items: const [
                        DropdownMenuItem(value: "sick", child: Text("Sakit")),
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
                      onChanged: (val) => setState(() => _jenis = val),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // TANGGAL MULAI
                buildField(
                  label: "Tanggal Mulai",
                  icon: Icons.calendar_month,
                  child: GestureDetector(
                    onTap: _pickStartDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _startDate == null
                            ? "Pilih tanggal"
                            : DateFormat('d MMM yyyy').format(_startDate!),
                        style: TextStyle(
                          color: _startDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // TANGGAL SELESAI
                buildField(
                  label: "Tanggal Selesai",
                  icon: Icons.calendar_today,
                  child: GestureDetector(
                    onTap: _pickEndDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _endDate == null
                            ? "Pilih tanggal"
                            : DateFormat('d MMM yyyy').format(_endDate!),
                        style: TextStyle(
                          color: _endDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ALASAN
                buildField(
                  label: "Alasan",
                  icon: Icons.edit_note,
                  child: TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Tulis alasan izin / cuti",
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Wajib diisi" : null,
                  ),
                ),

                const SizedBox(height: 18),

                // ATTACHMENT
                buildField(
                  label: "Lampiran (Opsional)",
                  icon: Icons.attach_file,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _attachment != null
                              ? _attachment!.path.split('/').last
                              : "Belum ada file",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickAttachment,
                        child: const Text("Pilih"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "KIRIM",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
