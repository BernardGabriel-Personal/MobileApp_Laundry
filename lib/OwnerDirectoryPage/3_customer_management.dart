import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerManagementPage extends StatelessWidget {
  const CustomerManagementPage({super.key});

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
                      color: const Color(0xFF3B5D74),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 3,
                    radius: const Radius.circular(10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('customers')
                          .orderBy('fullName')
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No customers found.'));
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var customer = snapshot.data!.docs[index];

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: const CircleAvatar(
                                  backgroundColor:  const Color(0xFF04D26F),
                                  child: Icon(Icons.person_outline, color: Colors.white),
                                ),
                                title: Text(
                                  customer['fullName'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF3B5D74),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Email: ${customer['email'] ?? 'N/A'}\n'
                                        'Contact: ${customer['contact'] ?? 'N/A'}\n'
                                        'Address: ${customer['address'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
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
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.grey[600],
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
