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
  void _showOrderDetails(Map<String, dynamic> data) async {
    final pricingSnapshot = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();

    final Map<String, dynamic> pricingData = pricingSnapshot.data() ?? {};
    final List<dynamic> preferredDetergents = data['preferredDetergents'] ?? [];
    final List<dynamic> items = data['items'] ?? [];

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
              if (data['rushOrder'] == true)
                _detailRow('Rush Order', 'Yes (Complete Today)'),
              const SizedBox(height: 10),

              _detailRow('Staff', (data['staffName'] ?? '').toString().isEmpty ? '—' : data['staffName']),
              _detailRow('Staff Contact', (data['staffContact'] ?? '').toString().isEmpty ? '—' : data['staffContact']),
              const Divider(),

              // Temporary Assigned Rider Info (placeholder)
              _detailRow('Assigned Rider', '—'),
              _detailRow('Rider Contact', '—'),
              const SizedBox(height: 10),

              _detailRow('Customer', data['fullName']),
              _detailRow('Contact', data['contact']),
              const Divider(),
              _detailRow('Order Method', data['orderMethod']),
              _detailRow('Payment', data['paymentMethod']),
              const Divider(),

              // Service Summary Cards
              ...items.map((item) {
                final m = Map<String, dynamic>.from(item);
                final serviceType = (m['serviceType'] ?? '').toString();

                final Map<String, dynamic> bulkyMap = Map<String, dynamic>.from(
                    m['numberOfBulkyItems'] ?? m['bulkyItems'] ?? {});
                final bulkyList = bulkyMap.entries.isEmpty
                    ? '—'
                    : bulkyMap.entries.map((e) => '${e.key} – ${e.value}').join(', ');

                final laundryList = (m['typeOfLaundry'] as List<dynamic>?)?.join(', ') ?? '—';

                // Custom logic for base and bulky pricing
                final double computedBasePrice;
                String baseLabel;

                switch (serviceType) {
                  case 'Iron Pressing':
                    computedBasePrice = (m['pressOnlyPrice'] ?? 0).toDouble();
                    baseLabel = '₱ ${computedBasePrice.toStringAsFixed(2)}';
                    break;
                  case 'Wash, Dry & Press':
                    computedBasePrice = (m['washDryPressPrice'] ?? 0).toDouble();
                    baseLabel = '₱ ${computedBasePrice.toStringAsFixed(2)}';
                    break;
                  case 'Wash Cleaning':
                    final washBase = (m['washBase'] ?? 0).toDouble();
                    final typeOfLaundry = (m['typeOfLaundry'] ?? []) as List<dynamic>;
                    final hasDelicates = typeOfLaundry.contains('Delicates');
                    computedBasePrice = hasDelicates ? washBase * 2 : washBase;
                    baseLabel = hasDelicates
                        ? '₱ ${washBase.toStringAsFixed(2)} x2 (Delicates | Hand-Wash)'
                        : '₱ ${washBase.toStringAsFixed(2)}';
                    break;
                  case 'Accessory Cleaning':
                    computedBasePrice = (pricingData['shoesBagHelmet'] ?? 0).toDouble();
                    baseLabel = '₱ ${computedBasePrice.toStringAsFixed(2)}';
                    break;
                  case 'Dry Cleaning':
                    computedBasePrice = (pricingData['dry'] ?? 0).toDouble();
                    baseLabel = '₱ ${computedBasePrice.toStringAsFixed(2)}';
                    break;
                  default:
                    computedBasePrice = 0.0;
                    baseLabel = '₱ 0.00';
                }


                final bulkyPrice = () {
                  if (serviceType == 'Wash Cleaning' || serviceType == 'Dry Cleaning') {
                    return m['priceOfBulkyItems'] ?? 0;
                  }
                  return 0;
                }();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(serviceType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    _miniRow('Base Price', baseLabel),
                    if (bulkyPrice > 0)
                      _miniRow('Bulky Items Price', '₱ ${bulkyPrice.toStringAsFixed(2)}'),
                    if ((m['bulkyPrice'] ?? 0) > 0)
                      _miniRow('Bulky / Accessory Price', '₱ ${(m['bulkyPrice'] ?? 0).toStringAsFixed(2)}'),
                    const Divider(),
                    _miniRow('Service Total', '₱ ${(m['totalPrice'] ?? 0).toStringAsFixed(2)}'),
                    if (serviceType.toLowerCase() != 'accessory cleaning')
                      _miniRow('Items', laundryList),
                    if (serviceType.toLowerCase() != 'iron pressing' &&
                        serviceType.toLowerCase() != 'wash, dry & press')
                      _miniRow('Bulky / Accessories', bulkyList),
                    _miniRow('Personalized Request',
                        (m['personalRequest'] ?? '').toString().trim().isNotEmpty ? m['personalRequest'] : '—'),
                  ]),
                );
              }),

              const Divider(),
              if ((data['deliveryFee']?['note'] ?? '').toString().trim().isNotEmpty)
                _detailRow('Delivery/Pickup Fee', data['deliveryFee']['note']),

              if ((data['detergentTotal'] ?? 0) > 0)
                _detailRow('Detergent/Softener Cost', '₱ ${data['detergentTotal'].toStringAsFixed(2)}'),

              _detailRow(
                'Grand Total',
                '₱ ${data['grandTotal'].toStringAsFixed(2)}',
                bold: true,
                color: const Color(0xFF04D26F),
                fontSize: 18,
              ),

              const SizedBox(height: 12),
              if (preferredDetergents.isNotEmpty) ...[
                const Text('Preferred Detergents / Softeners:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),

                ...preferredDetergents.map((d) {
                  if (d is Map<String, dynamic>) {
                    final name = d['label'] ?? d['price'] ?? 'Unnamed';
                    final rawPrice = d['pricingPerLoad'] ?? d['price'] ?? 0;
                    final price = rawPrice is int ? rawPrice.toDouble() : rawPrice;

                    // Determine how many detergent-eligible services exist
                    int multiplier = 1;
                    if (items.isNotEmpty) {
                      multiplier = items
                          .where((item) {
                        final type = (item['serviceType'] ?? '').toString().toLowerCase();
                        return type == 'wash cleaning' || type == 'wash, dry & press';
                      })
                          .length;
                    }

                    // Calculate total if multi-service and more than one relevant service
                    final bool isMulti = items.length > 1 && multiplier > 1;
                    final totalCost = price * multiplier;

                    final priceText = isMulti
                        ? '₱${price.toStringAsFixed(2)} per load x$multiplier = ₱${totalCost.toStringAsFixed(2)}'
                        : '₱${(price % 1 == 0) ? price.toInt() : price.toStringAsFixed(2)} Per-Load';

                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                      child: Text('- $name: $priceText'),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                      child: Text('- $d'),
                    );
                  }
                }),

                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Note: Detergent/Softener multiplier applies based on the number of '
                            'Wash Cleaning or Wash, Dry & Press services in this order.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Final pricing will appear on your invoice after weighing. Delivery/pick-up fees apply.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ],
              ),
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


  Widget _detailRow(String label, String value, {bool bold = false, Color? color, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: '),
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
                                        'If you chose pick-up, our rider will collect your clothes. \n'
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
