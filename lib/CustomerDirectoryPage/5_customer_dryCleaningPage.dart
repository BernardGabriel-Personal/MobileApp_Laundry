import 'package:flutter/material.dart';

class DryCleaningPage extends StatelessWidget {
  const DryCleaningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dry Cleaning'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Details about Dry Cleaning Service',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
