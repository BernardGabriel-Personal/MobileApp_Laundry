import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../AdminDirectoryPage/1_admin_homepage.dart';
import '2_admin_profilePage.dart';
import '../Start,Signup,Login/2_welcome_page.dart';

class AdminBasketPage extends StatefulWidget {
  final String fullName;
  final String branch;
  final String employeeId;
  final String email;
  final String contact;

  const AdminBasketPage({
    Key? key,
    required this.fullName,
    required this.branch,
    required this.employeeId,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<AdminBasketPage> createState() => _AdminBasketPageState();
}

class _AdminBasketPageState extends State<AdminBasketPage> {
  /* ───────── Logout confirmation ───────── */
  Future<bool> _confirmLogout(BuildContext ctx) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Color(0xFFE57373), size: 28),
            SizedBox(width: 10),
            Text('Are you leaving?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You can always log back in at any time.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return res == true;
  }

  /* ───────── Completion confirmation ───────── */
  Future<bool> _confirmCompletion(BuildContext ctx) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: Color(0xFF04D26F), size: 28),
            SizedBox(width: 10),
            Text('Confirm completion', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Is this order delivered / picked-up by the customer?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('No'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF04D26F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return res == true;
  }

  /* ───────── Reusable detail helpers ───────── */
  Widget _detailRow(String l, dynamic v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$l: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Expanded(child: Text('$v')),
      ],
    ),
  );

  Widget _miniRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$l: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(v)),
      ],
    ),
  );

  /* ───────── AUDIT helpers ───────── */
  void _promptAudit(DocumentSnapshot docSnap) {
    final data = docSnap.data() as Map<String, dynamic>;
    final TextEditingController controller =
    TextEditingController(text: (data['grandTotal'] ?? '').toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Final Grand Total'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₱ ', hintText: '0.00'),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: const Color(0xFF170CFE), foregroundColor: Colors.white),
            child: const Text('Save'),
            onPressed: () async {
              final newTotal = double.tryParse(controller.text.replaceAll(',', '').trim());
              if (newTotal == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFFE57373),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 4),
                    content: Row(
                      children: const [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please enter a valid number',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                return;
              }

              // Mark order as audited and ready for delivery / pick-up
              await docSnap.reference.update({
                'grandTotal': newTotal,
                'isAudited': true,
                'status': 'For delivery/pick-up',
              });

              // Save or update the invoice in customer_invoice collection
              final invoiceRef = FirebaseFirestore.instance
                  .collection('customer_invoice')
                  .doc(docSnap.id);

              await invoiceRef.set({
                ...data,
                'grandTotal': newTotal,
                'isAudited': true,
                'status': 'For delivery/pick-up',
                'invoiceTimestamp': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              if (mounted) Navigator.pop(context); // close input dialog
              if (mounted) Navigator.pop(context); // close order details dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:  const Color(0xFF04D26F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 4),
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Grand Total successfully updated!',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );

            },
          ),
        ],
      ),
    );
  }

  /* ───────── Order details dialog ───────── */
  void _showOrderDetails(DocumentSnapshot docSnap) {
    final data = docSnap.data() as Map<String, dynamic>;
    final isCompleted = (data['status'] ?? '').toString().toLowerCase() == 'completed';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[100],
        title: Row(
          children: [
            const Icon(Icons.description, color: Color(0xFF170CFE)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Order #${data['orderId']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Branch', data['branch']),
              _detailRow('Status', data['status']),
              _detailRow('Staff', data['staffName']),
              _detailRow('Staff Contact', data['staffContact']),
              _detailRow('Customer', data['fullName']),
              _detailRow('Customer Address', data['address']),
              _detailRow('Contact', data['contact']),
              const Divider(),
              _detailRow('Order Method', data['orderMethod']),
              _detailRow('Payment', data['paymentMethod']),
              _detailRow('Preferred Detergents', (data['preferredDetergents'] as List<dynamic>?)?.join(', ') ?? '—'),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₱ ${data['grandTotal']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF04D26F)),
                  ),
                ],
              ),
              if (data['isAudited'] != true)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Please audit the final price to confirm the accurate weight of customer items and include any applicable delivery or pick-up fees.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              ...(data['items'] as List<dynamic>).map((item) {
                final m = Map<String, dynamic>.from(item);
                final laundry = (m['typeOfLaundry'] as List<dynamic>?)?.join(', ') ?? '—';
                final bulkyMap = Map<String, dynamic>.from(m['numberOfBulkyItems'] ?? {});
                final bulky = bulkyMap.isEmpty ? '—' : bulkyMap.entries.map((e) => '${e.key} – ${e.value}').join(', ');
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['serviceType'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      _miniRow('Regular Items', laundry.isEmpty ? '—' : laundry),
                      _miniRow('Bulky / Accessory', bulky.isEmpty ? '—' : bulky),
                      _miniRow('Personal Request', (m['personalRequest'] ?? '').toString().isEmpty ? '—' : m['personalRequest']),
                      _miniRow('Item Total', '₱ ${m['totalPrice'] ?? 0}'),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: data['isAudited'] == true ? Colors.grey : const Color(0xFF170CFE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(data['isAudited'] == true ? 'Audited' : 'Audit'),
            onPressed: data['isAudited'] == true ? null : () => _promptAudit(docSnap),
          ),
          if (_isReadyStatus(data['status'] ?? '') && !isCompleted)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: isCompleted ? Colors.grey : const Color(0xFF04D26F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('completed'),
              onPressed: isCompleted
                  ? null
                  : () async {
                if (!await _confirmCompletion(context)) return;

                await docSnap.reference.update({
                  'status': 'completed',
                  'completionTimestamp': FieldValue.serverTimestamp(),
                });

                // Save or update the invoice in customer_invoice collection
                final invoiceRef = FirebaseFirestore.instance
                    .collection('customer_invoice')
                    .doc(docSnap.id);

                await invoiceRef.set({
                  ...data,
                  'status': 'completed',
                  'completionTimestamp': FieldValue.serverTimestamp(),
                  'invoiceTimestamp': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                if (mounted) Navigator.pop(context); // close detail dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor:  const Color(0xFF04D26F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 4),
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Order marked as completed!',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /* ───────── Helpers to categorize orders ───────── */
  bool _isReadyStatus(String status) {
    final s = status.toLowerCase();
    return s.contains('ready') || s.contains('pick-up') || s.contains('delivery');
  }

  bool _isCompletedStatus(String status) {
    return status.toLowerCase() == 'completed';
  }

  /* ───────── UI ───────── */
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _confirmLogout(context)) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECF0F1),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF170CFE),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          onTap: (i) async {
            switch (i) {
              case 0:
                if (await _confirmLogout(context)) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(pageBuilder: (_, __, ___) => const HomeScreen(), transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero),
                  );
                }
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => AdminHomePage(
                      fullName: widget.fullName,
                      branch: widget.branch,
                      employeeId: widget.employeeId,
                      email: widget.email,
                      contact: widget.contact,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => AdminProfilePage(
                      fullName: widget.fullName,
                      branch: widget.branch,
                      employeeId: widget.employeeId,
                      email: widget.email,
                      contact: widget.contact,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Basket'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF170CFE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shopping_basket, color: Colors.white, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Your Laundry Basket',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customer_orders')
                      .where('staffName', isEqualTo: widget.fullName)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(child: Text('Your basket is empty.', style: TextStyle(fontSize: 18, color: Colors.grey[700])));
                    }

                    // Split orders into three categories
                    final completedDocs = <QueryDocumentSnapshot>[];
                    final readyDocs = <QueryDocumentSnapshot>[];
                    final processingDocs = <QueryDocumentSnapshot>[];
                    for (final d in docs) {
                      final status = (d['status'] ?? '').toString();
                      if (_isCompletedStatus(status)) {
                        completedDocs.add(d);
                      } else if (_isReadyStatus(status)) {
                        readyDocs.add(d);
                      } else if (status.toLowerCase() == 'processing') {
                        processingDocs.add(d);
                      }
                    }

                    List<Widget> children = [];

                    /* ───────── Section 1 – Completed ───────── */
                    children.add(const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('• Completed laundry orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ));

                    if (completedDocs.isEmpty) {
                      children.add(const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('No completed orders yet.'),
                      ));
                    } else {
                      children.addAll(completedDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text('Order #${data['orderId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Assigned Staff: ${data['staffName']} • ${data['status']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showOrderDetails(doc),
                          ),
                        );
                      }));
                    }

                    /* ───────── Section 2 – Ready to deliver / pick-up ───────── */
                    children.add(const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('• Ready to deliver / for customer pick-up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ));

                    if (readyDocs.isEmpty) {
                      children.add(const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('No orders are ready yet.'),
                      ));
                    } else {
                      children.addAll(readyDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text('Order #${data['orderId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Assigned Staff: ${data['staffName']} • ${data['status']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showOrderDetails(doc),
                          ),
                        );
                      }));
                    }

                    /* ───────── Section 3 – Processing ───────── */
                    children.add(const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('• Processing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ));

                    if (processingDocs.isEmpty) {
                      children.add(const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('No orders are currently processing.'),
                      ));
                    } else {
                      children.addAll(processingDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text('Order #${data['orderId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Assigned Staff: ${data['staffName']} • ${data['status']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showOrderDetails(doc),
                          ),
                        );
                      }));
                    }

                    return ListView(padding: EdgeInsets.zero, children: children);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ───────── Clean-up ───────── */
  @override
  void dispose() {
    super.dispose();
  }
}
