import 'package:flutter/material.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Izin")),
      body: Center(child: Text("Data riwayat tampil disini")),
    );
  }
}
