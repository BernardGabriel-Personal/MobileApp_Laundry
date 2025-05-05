import 'package:flutter/material.dart';

class StainRemovalPage extends StatelessWidget {
  const StainRemovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stain Removal'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Details about Stain Removal Service',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
