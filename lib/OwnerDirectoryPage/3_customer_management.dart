import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({super.key});

  @override
  State<CustomerManagementPage> createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  bool _isDeleting = false;

  // ───────────────────────── delete helpers ─────────────────────────
  Future<void> _confirmAndDelete(
      String customerId,
      String customerName,
      String email,
      ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF6E9D4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'Delete Customer',
            style: TextStyle(
              color: const Color(0xFFE57373),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$customerName"?\n\n'
              'This will permanently remove their record from:\n'
              '• customers\n• cart_customers',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 10),
        actions: [
          // cancel
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[500],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // confirm delete
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await _deleteCustomer(customerId, email);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(String customerId, String email) async {
    setState(() => _isDeleting = true);

    try {
      // 1. delete from customers
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .delete();

      // 2. delete all matching entries from cart_customers
      final cartSnap = await FirebaseFirestore.instance
          .collection('cart_customers')
          .where('email', isEqualTo: email)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in cartSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        _showSnack('Customer deleted successfully!');
      }
    } catch (e) {
      _showSnack('Error deleting customer: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF160EF5),
      ),
    );
  }

  // ───────────────────────── ui ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9D4),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Center(
                  child: Text(
                    'Customer Records',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B5D74),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 3,
                    radius: const Radius.circular(10),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('customers')
                          .orderBy('fullName')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            _isDeleting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No customers found.'));
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final customer = snapshot.data!.docs[index];
                            final String name = customer['fullName'] ?? 'No Name';
                            final String email = customer['email'] ?? '';

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF04D26F),
                                  child:
                                  Icon(Icons.person_outline, color: Colors.white),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF3B5D74),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Email: $email\n'
                                        'Contact: ${customer['contact'] ?? 'N/A'}\n'
                                        'Address: ${customer['address'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                trailing: TextButton(
                                  onPressed: () => _confirmAndDelete(
                                    customer.id,
                                    name,
                                    email,
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color(0xFFE57373),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30), // round button
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                ),


                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // back arrow
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.grey[600],
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
