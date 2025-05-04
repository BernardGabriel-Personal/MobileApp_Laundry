import 'package:flutter/material.dart';

class WashAndFoldPage extends StatelessWidget {
  const WashAndFoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wash and Fold'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Details about Wash and Fold Service',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
