import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Start,Signup,Login/2_welcome_page.dart'; // logout → HomeScreen
import '1_customer_homepage.dart';
import '8_customer_profilePage.dart';
import '9_customer_orderingPage.dart'; // Import OrderingPage

class CartPage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const CartPage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<String, bool> _checked = {};

  Future<bool> _confirmLogout(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _styledAlert(
        icon: Icons.error_outline,
        iconColor: const Color(0xFFE57373),
        title: 'Are you leaving?',
        message:
        'Are you sure you want to log out? You can always log back in at any time.',
        okLabel: 'Logout',
        cancelLabel: 'Cancel',
      ),
    );
    return res == true;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _styledAlert(
        icon: Icons.delete_outline,
        iconColor: const Color(0xFFE57373),
        title: 'Delete item?',
        message: 'This will remove the item from your cart! Please check carefully.',
        okLabel: 'Delete',
        cancelLabel: 'Cancel',
      ),
    );
    return res == true;
  }

  double _selectedTotal(Iterable<QueryDocumentSnapshot> docs) {
    double sum = 0;
    for (final d in docs) {
      if (_checked[d.id] == true) {
        sum += (d['totalPrice'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  Future<void> _deleteDoc(String docId) async =>
      FirebaseFirestore.instance.collection('cart_customers').doc(docId).delete();

  Future<void> _deleteSelected(Iterable<QueryDocumentSnapshot> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final d in docs) {
      if (_checked[d.id] == true) batch.delete(d.reference);
    }
    await batch.commit();
    _checked.clear();
  }

  AlertDialog _styledAlert({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String okLabel,
    required String cancelLabel,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFFD9D9D9),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 18)),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 14)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: iconColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(okLabel),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmLogout(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECF0F3),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                color: const Color(0xFF04D26F),
                child: Row(
                  children: const [
                    Icon(Icons.shopping_cart, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Your Laundry Cart',
                        style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cart_customers')
                      .where('email', isEqualTo: widget.email)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data?.docs ?? [];
                    final ids = docs.map((e) => e.id).toSet();
                    _checked.removeWhere((k, _) => !ids.contains(k));
                    for (final d in docs) {
                      _checked.putIfAbsent(d.id, () => false);
                    }

                    if (docs.isEmpty) {
                      return const Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final d = docs[i];
                        final docId = d.id;
                        final service = d['serviceType'] ?? 'Service';
                        final total = (d['totalPrice'] ?? 0).toDouble();
                        final typeOfLaundry = d['typeOfLaundry'] as List? ?? [];
                        final numberOfBulkyItems = d['numberOfBulkyItems'] as Map? ?? {};

                        String formatBulkyItems(Map itemsMap) {
                          return itemsMap.entries.map((e) => '${e.value}x ${e.key}').join(', ');
                        }

                        final preview = [
                          if (typeOfLaundry.isNotEmpty) typeOfLaundry.join(', '),
                          if (numberOfBulkyItems.isNotEmpty)
                            formatBulkyItems(numberOfBulkyItems.cast<String, dynamic>())
                        ].join(' · ');

                        return Card(
                          color: Colors.grey[200],
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: _checked[docId] ?? false,
                                      activeColor: const Color(0xFF04D26F),
                                      onChanged: (v) => setState(() => _checked[docId] = v ?? false),
                                    ),
                                    Expanded(
                                      child: Text(service,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                    ),
                                    Text('₱ ${total.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: const Color(0xFFE57373),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Delete'),
                                      onPressed: () async {
                                        if (await _confirmDelete(context)) {
                                          await _deleteDoc(docId);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
                                  child: Text(preview,
                                      style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cart_customers')
                    .where('email', isEqualTo: widget.email)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (_, snap) {
                  final docs = snap.data?.docs ?? [];
                  final allSelected = docs.isNotEmpty && docs.every((d) => _checked[d.id] == true);
                  final totalSel = _selectedTotal(docs);
                  final hasChecked = totalSel > 0;

                  final selectedDocs = docs.where((d) => _checked[d.id] == true).toList();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: allSelected,
                              activeColor: const Color(0xFF04D26F),
                              onChanged: docs.isEmpty
                                  ? null
                                  : (v) => setState(() => _checked.updateAll((_, __) => v ?? false)),
                            ),
                            const Text('Select All', style: TextStyle(fontSize: 16)),
                            const Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: hasChecked ? const Color(0xFFE57373) : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: hasChecked
                                  ? () async {
                                if (await _confirmDelete(context)) {
                                  await _deleteSelected(docs);
                                }
                              }
                                  : null,
                              child: const Text('Delete'),
                            ),
                            const SizedBox(width: 8),
                            Text('Total: ₱ ${totalSel.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF170CFE),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: hasChecked
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderingPage(
                                    fullName: widget.fullName,
                                    address: widget.address,
                                    contact: widget.contact,
                                    email: widget.email,
                                    selectedItems: selectedDocs,
                                    totalPrice: totalSel,
                                  ),
                                ),
                              );
                            }
                                : null,
                            child: const Text('Check Out',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF04D26F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (i) {
            switch (i) {
              case 2:
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CustomerHomePage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 4:
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CustomerProfilePage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoice'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
