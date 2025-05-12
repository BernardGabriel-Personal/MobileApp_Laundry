import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDetergentPage extends StatefulWidget {
  final String employeeId;
  final String branch;

  const AdminDetergentPage({
    super.key,
    required this.employeeId,
    required this.branch,
  });

  @override
  State<AdminDetergentPage> createState() => _AdminDetergentPageState();
}

class _AdminDetergentPageState extends State<AdminDetergentPage> {
  final TextEditingController _typeController = TextEditingController();
  String? _selectedAvailability;

  final List<String> _availabilityOptions = ['Yes', 'No'];
  final Color highlightColor = const Color(0xFF04D26F);

  Future<void> _submitForm() async {
    final String type = _typeController.text.trim();
    final String? availability = _selectedAvailability;

    if (type.isEmpty || availability == null) {
      _showCustomSnackBar('Please fill all fields!', isError: true);
      return;
    }

    final existing = await FirebaseFirestore.instance
        .collection('detergent_management')
        .where('detergentSoftener', isEqualTo: type)
        .where('branch', isEqualTo: widget.branch)
        .get();

    if (existing.docs.isNotEmpty) {
      _showCustomSnackBar('Detergent/Softener already exists.', isError: true);
      return;
    }

    await FirebaseFirestore.instance.collection('detergent_management').add({
      'employeeId': widget.employeeId,
      'detergentSoftener': type,
      'availability': availability,
      'branch': widget.branch,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _showCustomSnackBar('Detergent added successfully!', isError: false);

    _typeController.clear();
    setState(() {
      _selectedAvailability = null;
    });
  }

  void _showCustomSnackBar(String message, {required bool isError}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: isError ? const Color(0xFFE57373) : highlightColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _updateAvailability(String docId, dynamic currentValue) async {
    final newValue = (currentValue == true || currentValue == 'Yes') ? 'No' : 'Yes';
    await FirebaseFirestore.instance
        .collection('detergent_management')
        .doc(docId)
        .update({'availability': newValue});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170CFE),
        title: const Text(
          'Detergent Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: highlightColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Laundry Detergent / Fabric Softener',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF170CFE),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText: 'Laundry Detergent/Fabric Softener',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: highlightColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedAvailability,
                  items: _availabilityOptions
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAvailability = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Availability',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: highlightColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Detergent/Softener',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(thickness: 2),
                const SizedBox(height: 10),
                const Text(
                  'Existing Detergents/Softeners',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF170CFE),
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('detergent_management')
                      .where('branch', isEqualTo: widget.branch)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'No detergents/softeners found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final detergentName = data['detergentSoftener'] ?? '';
                        final employeeId = data['employeeId'] ?? '';
                        final rawAvailability = data['availability'];
                        final availability = (rawAvailability == true || rawAvailability == 'Yes') ? 'Yes' : 'No';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(detergentName),
                            subtitle: Text('Added by: ID - $employeeId'),
                            trailing: GestureDetector(
                              onTap: () {
                                _updateAvailability(docId, availability);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: availability == 'Yes' ? const Color(0xFF04D26F) : const Color(0xFFE57373),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  availability,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
