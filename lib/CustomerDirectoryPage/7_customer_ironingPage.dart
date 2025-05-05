import 'package:flutter/material.dart';

class IroningPage extends StatelessWidget {
  const IroningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ironing Service'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Details about Ironing Service',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
