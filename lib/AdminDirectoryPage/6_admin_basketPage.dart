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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return res == true;
  }

  /* ───────── Reusable detail helpers (for dialog) ───────── */
  Widget _detailRow(String l, dynamic v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$l: ',
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Expanded(child: Text('$v')),
      ],
    ),
  );

  Widget _miniRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$l: ',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(v)),
      ],
    ),
  );

  void _showOrderDetails(Map<String, dynamic> data) {
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
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
              _detailRow(
                  'Preferred Detergents',
                  (data['preferredDetergents'] as List<dynamic>?)
                      ?.join(', ') ??
                      '—'),
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
                      'Please audit the final price to confirm the accurate weight of customer items and include any applicable delivery or pick-up fees.',
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              ...(data['items'] as List<dynamic>).map((item) {
                final m = Map<String, dynamic>.from(item);
                final laundry =
                    (m['typeOfLaundry'] as List<dynamic>?)?.join(', ') ?? '—';
                final bulkyMap =
                Map<String, dynamic>.from(m['numberOfBulkyItems'] ?? {});
                final bulky = bulkyMap.isEmpty
                    ? '—'
                    : bulkyMap.entries
                    .map((e) => '${e.key} – ${e.value}')
                    .join(', ');
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
                      _miniRow('Regular Items', laundry.isEmpty ? '—' : laundry),
                      _miniRow('Bulky / Accessory', bulky.isEmpty ? '—' : bulky),
                      _miniRow(
                          'Personal Request',
                          (m['personalRequest'] ?? '').toString().isEmpty
                              ? '—'
                              : m['personalRequest']),
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
              backgroundColor: const Color(0xFF170CFE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Audit'),
            onPressed: () {
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],

      ),
    );
  }

  /* ───────── UI ───────── */
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _confirmLogout(context)) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
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
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket), label: 'Basket'),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customer_orders')
                      .where('status', isEqualTo: 'processing')
                      .where('staffName', isEqualTo: widget.fullName)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('Your basket is empty.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final data =
                        docs[i].data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text('Order #${data['orderId']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Assigned Staff: ${data['staffName']} • ${data['status']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showOrderDetails(data),
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
      ),
    );
  }
}