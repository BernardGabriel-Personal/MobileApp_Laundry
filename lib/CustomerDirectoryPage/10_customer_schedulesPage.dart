import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Start,Signup,Login/2_welcome_page.dart'; // logout → HomeScreen
import '1_customer_homepage.dart';
import '8_customer_profilePage.dart';
import '7_customer_cartPage.dart';
import '11_customer_invoicePage.dart';

class scheduledOrderPage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const scheduledOrderPage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<scheduledOrderPage> createState() => _scheduledOrderPageState();
}

class _scheduledOrderPageState extends State<scheduledOrderPage> {
/* ───────── CONFIRM LOG-OUT ───────── */
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
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: iconColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(okLabel),
        ),
      ],
    );
  }

/* ───────── ORDER DETAIL DIALOG ───────── */
  void _showOrderDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[100],
        title: Row(
          children: [
            const Icon(Icons.description, color: Color(0xFF04D26F)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Order #${data['orderId'] ?? ''}',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Branch', data['branch']),
              _detailRow('Status', data['status']),
              _detailRow('Staff',
                  (data['staffName'] ?? '').toString().isEmpty ? '—' : data['staffName']),
              _detailRow('Staff Contact',
                  (data['staffContact'] ?? '').toString().isEmpty ? '—' : data['staffContact']),
              _detailRow('Customer', data['fullName']),
              _detailRow('Contact', data['contact']),
              const Divider(),
              _detailRow('Order Method', data['orderMethod']),
              _detailRow('Payment', data['paymentMethod']),
              _detailRow(
                'Preferred Detergents',
                (data['preferredDetergents'] as List<dynamic>?)
                    ?.join(', ') ??
                    '—',
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₱ ${data['grandTotal']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF04D26F),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Final pricing will appear on your invoice after weighing. Delivery/pick-up fees apply.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Items:',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              ...(data['items'] as List<dynamic>).map((item) {
                final m = Map<String, dynamic>.from(item);

                Map<String, dynamic> bulkyMap =
                Map<String, dynamic>.from(m['numberOfBulkyItems'] ?? {});

                if (bulkyMap.isEmpty) {
                  if (m['bulkyItems'] is Map) {
                    bulkyMap = Map<String, dynamic>.from(m['bulkyItems']);
                  } else if (m['bulkyItems'] is List) {
                    final lst = (m['bulkyItems'] as List).cast<dynamic>();
                    bulkyMap = {for (var e in lst) e.toString(): 1};
                  }
                }

                final bulkyList = bulkyMap.isEmpty
                    ? '—'
                    : bulkyMap.entries
                    .map((e) => '${e.key} – ${e.value}')
                    .join(', ');

                final laundry =
                    (m['typeOfLaundry'] as List<dynamic>?)?.join(', ') ?? '—';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['serviceType'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        _miniRow('Laundry Items',
                            laundry.isEmpty ? '—' : laundry),
                        _miniRow('Bulky / Accessory',
                            bulkyList.isEmpty ? '—' : bulkyList),
                        _miniRow(
                          'Personal Request',
                          (m['personalRequest'] ?? '').toString().isEmpty
                              ? '—'
                              : m['personalRequest'],
                        ),
                        _miniRow('Item Total', '₱ ${m['totalPrice'] ?? 0}'),
                      ]),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF04D26F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text('$value')),
      ],
    ),
  );

  Widget _miniRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    ),
  );

/* ───────── BUILD ───────── */
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFF04D26F),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.schedule, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Track Your Scheduled Order',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customer_orders')
                      .where('email', isEqualTo: widget.email)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    // Filter only "processing" and "pending"
                    final processingDocs = docs
                        .where((d) => (d['status'] as String).toLowerCase() == 'processing')
                        .toList();

                    final pendingDocs = docs
                        .where((d) => (d['status'] as String).toLowerCase() == 'pending')
                        .toList();

                    // If both lists are empty, show message
                    if (processingDocs.isEmpty && pendingDocs.isEmpty) {
                      return Center(
                        child: Text(
                          'No scheduled orders yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                      );
                    }

                    // Helper to build section
                    List<Widget> section(List<QueryDocumentSnapshot> list) {
                      return list
                          .map((e) => Card(
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            'Order #${e['orderId'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${e['branch']} • ${e['status']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              _showOrderDetails(e.data() as Map<String, dynamic>),
                        ),
                      ))
                          .toList();
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (processingDocs.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Processing',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFFFD700),
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Please expect a message from our laundry staff. \n'
                                        'If you chose pick-up, our staff will collect your clothes. \n'
                                        'If you selected drop-off, kindly proceed to your chosen laundry branch.',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        ...section(processingDocs),

                        if (pendingDocs.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Pending',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...section(pendingDocs),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF04D26F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 3,
          onTap: (i) {
            switch (i) {
              case 0: // Cart
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CartPage(
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
              case 1: // Invoice
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => customerInvoicePage(
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
              case 2: // Home
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
              case 4: // Profile
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
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Invoice'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), label: 'Schedules'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
