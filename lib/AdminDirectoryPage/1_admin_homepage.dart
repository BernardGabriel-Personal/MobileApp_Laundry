import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Homepage'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Welcome, Admin!\nCODING IN PROGRESS',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
