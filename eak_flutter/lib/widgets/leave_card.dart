import 'package:flutter/material.dart';

class LeaveCard extends StatelessWidget {
  final String jenis;
  final String start;
  final String end;
  final String status;

  const LeaveCard({
    super.key,
    required this.jenis,
    required this.start,
    required this.end,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.event),
        title: Text(jenis),
        subtitle: Text("$start → $end"),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == "pending"
                ? Colors.orange
                : status == "approved"
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}