import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Start,Signup,Login/2_welcome_page.dart';   // logout → HomeScreen
import '1_customer_homepage.dart';
import '8_customer_profilePage.dart';
import '7_customer_cartPage.dart';
import '10_customer_schedulesPage.dart';

class customerInvoicePage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const customerInvoicePage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<customerInvoicePage> createState() => _customerInvoicePageState();
}

class _customerInvoicePageState extends State<customerInvoicePage> {
/* ───────── LOGOUT CONFIRMATION ───────── */
  Future<bool> _confirmLogout(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _styledAlert(
        icon: Icons.error_outline,
        iconColor: const Color(0xFFE57373),
        title: 'Are you leaving?',
        message: 'Are you sure you want to log out? You can always log back in at any time.',
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              _detailRow('Staff', (data['staffName'] ?? '').toString().isEmpty ? '—' : data['staffName']),
              _detailRow('Staff Contact', (data['staffContact'] ?? '').toString().isEmpty ? '—' : data['staffContact']),
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
                  const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('₱ ${data['grandTotal']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF04D26F))),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              ...(data['items'] as List<dynamic>).map((item) {
                final m = Map<String, dynamic>.from(item);

                // Handle bulky items regardless of structure
                Map<String, dynamic> bulkyMap = Map<String, dynamic>.from(m['numberOfBulkyItems'] ?? {});
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
                    : bulkyMap.entries.map((e) => '${e.key} – ${e.value}').join(', ');
                final laundry = (m['typeOfLaundry'] as List<dynamic>?)?.join(', ') ?? '—';

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
                      Text(m['serviceType'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      _miniRow('Regular Items', laundry.isEmpty ? '—' : laundry),
                      _miniRow('Bulky / Accessory', bulkyList.isEmpty ? '—' : bulkyList),
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
              backgroundColor: const Color(0xFF04D26F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text('$value')),
      ],
    ),
  );

  Widget _miniRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECF0F3),
        body: SafeArea(
          child: Column(
            children: [
              /* ── Header bar ── */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                    Text('Your Invoices', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              /* ── Stream of invoices ── */
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customer_invoice')
                      .where('email', isEqualTo: widget.email)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Text('No invoices yet.', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                      );
                    }

                    /* ── Filter by status ── */
                    final completedDocs = docs
                        .where((d) => (d['status'] as String).toLowerCase() == 'completed')
                        .toList();

                    final readyDocs = docs.where((d) {
                      final status = (d['status'] as String).toLowerCase();
                      return status.contains('delivery') || status.contains('pick');
                    }).toList();

                    List<Widget> _cards(List<QueryDocumentSnapshot> list) => list.map((e) {
                      return Card(
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          onTap: () => _showOrderDetails(e.data() as Map<String, dynamic>),
                        ),
                      );
                    }).toList();

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        /* ── Completed section ── */
                        if (completedDocs.isNotEmpty) ...[
                          const Text('Completed Laundry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: 8),
                          ..._cards(completedDocs),
                          const SizedBox(height: 20),
                        ],

                        /* ── Ready for Deliver / Pick-up section ── */
                        if (readyDocs.isNotEmpty) ...[
                          const Text('Ready for Deliver / Customer Pick-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: 8),
                          ..._cards(readyDocs),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        /* ─── BOTTOM NAVIGATION BAR ────────────────────────────────── */
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF04D26F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // Invoice tab
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

              case 3: // Schedules
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => scheduledOrderPage(
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
