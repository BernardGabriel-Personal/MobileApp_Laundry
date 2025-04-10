import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Homepage'),
        backgroundColor: Colors.green, // Change to a color of your choice
      ),
      body: const Center(
        child: Text(
          'Welcome, Customer!\nCODING IN PROGRESS',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
