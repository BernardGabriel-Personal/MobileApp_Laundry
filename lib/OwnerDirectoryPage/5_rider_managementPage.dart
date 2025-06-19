import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiderManagementPage extends StatefulWidget {
  const RiderManagementPage({super.key});

  @override
  State<RiderManagementPage> createState() => _RiderManagementPageState();
}

class _RiderManagementPageState extends State<RiderManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final CollectionReference _rider =
  FirebaseFirestore.instance.collection('rider');

  // Add new rider to Firestore
  Future<void> _addRider() async {
    if (_nameController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty) return;

    await _rider.add({
      'fullName': _nameController.text.trim(),
      'contactNumber': _numberController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _numberController.clear();
  }

  // Delete rider by ID
  Future<void> _deleteRider(String docId) async {
    await _rider.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170CFE),
        title: const Text("Rider Management"),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Contact Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04D26F),
                foregroundColor: Colors.white,
              ),
              onPressed: _addRider,
              icon: const Icon(Icons.add),
              label: const Text("Add Rider"),
            ),
            const SizedBox(height: 20),

            // Rider List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _rider.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final riders = snapshot.data?.docs ?? [];
                  if (riders.isEmpty) {
                    return const Center(child: Text("No riders added yet."));
                  }
                  return ListView.builder(
                    itemCount: riders.length,
                    itemBuilder: (context, index) {
                      final rider = riders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(rider['fullName'] ?? ''),
                          subtitle: Text("📞 ${rider['contactNumber'] ?? ''}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRider(rider.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
