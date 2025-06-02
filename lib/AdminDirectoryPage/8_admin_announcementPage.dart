import 'package:flutter/material.dart';

class AdminAnnouncementPage extends StatelessWidget {
  final String fullName;
  final String branch;
  final String employeeId;

  const AdminAnnouncementPage({
    Key? key,
    required this.fullName,
    required this.branch,
    required this.employeeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170CFE),
        title: const Text(
          'Announcement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name: $fullName'),
            Text('Branch: $branch'),
            Text('Employee ID: $employeeId'),
            const SizedBox(height: 20),
            // You can add log entries here later
            const Text(
              'Announcement will appear here...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}