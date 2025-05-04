import 'package:flutter/material.dart';

class RushServicePage extends StatelessWidget {
  const RushServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rush Service'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Details about Rush Service',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
