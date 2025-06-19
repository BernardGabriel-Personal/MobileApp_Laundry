import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderManagementPage extends StatelessWidget {
  final String branch;
  final String fullName;      // admin name
  final String employeeId;
  final String contact;       // admin contact

  const AdminOrderManagementPage({
    Key? key,
    required this.branch,
    required this.fullName,
    required this.employeeId,
    required this.contact,
  }) : super(key: key);

  /* ───────── Accept-order confirmation ───────── */
  Future<bool> _confirmAccept(BuildContext ctx) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        title: const Text('Accept this order?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'This will assign the order to you and move it to Processing.'),
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
              backgroundColor: const Color(0xFF170CFE),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return res == true;
  }

  /* ───────── ORDER-DETAIL dialog ───────── */
  void _showOrderDetails(BuildContext ctx, QueryDocumentSnapshot snap) async {
    final data = snap.data() as Map<String, dynamic>;

    final pricingSnapshot = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final Map<String, dynamic> pricingData = pricingSnapshot.data() ?? {};
    final List<dynamic> preferredDetergents = data['preferredDetergents'] ?? [];
    final List<dynamic> items = data['items'] ?? [];

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[100],
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
        title: Row(
          children: [
            const Icon(Icons.description, color: Color(0xFF170CFE)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Order #${data['orderId'] ?? ''}',
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
              if (data['rushOrder'] == true)
                _detailRow('Rush Order', 'Yes (Complete Today)'),
              const SizedBox(height: 10),

              _detailRow('Staff', (data['staffName'] ?? '').toString().isEmpty ? '—' : data['staffName']),
              _detailRow('Staff Contact', (data['staffContact'] ?? '').toString().isEmpty ? '—' : data['staffContact']),
              const Divider(),

              _detailRow('Assigned Rider', data['assignedRider'] ?? '—'),
              _detailRow('Rider Contact', data['riderContact'] ?? '—'),
              const SizedBox(height: 10),


              _detailRow('Customer', data['fullName']),
              _detailRow('Customer Address', data['address']),
              _detailRow('Contact', data['contact']),
              const Divider(),
              _detailRow('Order Method', data['orderMethod']),
              _detailRow('Payment', data['paymentMethod']),
              const Divider(),

              ...items.map((item) {
                final m = Map<String, dynamic>.from(item);
                final serviceType = (m['serviceType'] ?? '').toString();

                final Map<String, dynamic> bulkyMap = Map<String, dynamic>.from(
                    m['numberOfBulkyItems'] ?? m['bulkyItems'] ?? {});
                final bulkyList = bulkyMap.entries.isEmpty
                    ? '—'
                    : bulkyMap.entries.map((e) => '${e.key} – ${e.value}').join(', ');

                final laundryList = (m['typeOfLaundry'] as List<dynamic>?)?.join(', ') ?? '—';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      _miniRow('Base Price', baseLabel),
                      if (bulkyPrice > 0)
                        _miniRow('Bulky Items Price', '₱ ${bulkyPrice.toStringAsFixed(2)}'),
                      if ((m['bulkyPrice'] ?? 0) > 0)
                        _miniRow('Bulky / Accessory Price', '₱ ${(m['bulkyPrice'] ?? 0).toStringAsFixed(2)}'),
                      const Divider(),
                      _miniRow('Service Total', '₱ ${(m['totalPrice'] ?? 0).toStringAsFixed(2)}'),
                      _miniRow('Items', laundryList),
                      _miniRow('Bulky / Accessories', bulkyList),
                      _miniRow('Personalized Request',
                          (m['personalRequest'] ?? '').toString().trim().isNotEmpty
                              ? m['personalRequest']
                              : '—'),
                    ],
                  ),
                );
              }),

              const Divider(),
              if ((data['deliveryFee']?['note'] ?? '').toString().trim().isNotEmpty)
                _detailRow('Delivery/Pickup Fee', data['deliveryFee']['note']),

              if ((data['detergentTotal'] ?? 0) > 0)
                _detailRow('Detergent/Softener Cost', '₱ ${data['detergentTotal'].toStringAsFixed(2)}'),

              _detailRow('Grand Total', '₱ ${data['grandTotal'].toStringAsFixed(2)}',
                  bold: true, color: const Color(0xFF04D26F), fontSize: 18),

              if (preferredDetergents.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Preferred Detergents / Softeners:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                ...preferredDetergents.map((d) {
                  if (d is Map<String, dynamic>) {
                    final name = d['label'] ?? d['price'] ?? 'Unnamed';
                    final rawPrice = d['pricingPerLoad'] ?? d['price'] ?? 0;
                    final price = rawPrice is int ? rawPrice.toDouble() : rawPrice;

                    int multiplier = 1;
                    if (items.isNotEmpty) {
                      multiplier = items
                          .where((item) {
                        final type = (item['serviceType'] ?? '').toString().toLowerCase();
                        return type == 'wash cleaning' || type == 'wash, dry & press';
                      })
                          .length;
                    }

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
                const Text(
                  'Note: Detergent/Softener multiplier applies based on the number of '
                      'Wash Cleaning or Wash, Dry & Press services in this order.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 20),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Final pricing must be calculated after weighing the customer items.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        actions: [
          if ((data['status'] ?? '').toString().toLowerCase() == 'pending')
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF170CFE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!await _confirmAccept(ctx)) return;
                try {
                  await snap.reference.update({
                    'status': 'processing',
                    'staffName': fullName,
                    'staffContact': contact,
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF04D26F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Order accepted!',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFFE57373),
                      content: Text('Failed to accept order: $e'),
                    ),
                  );
                }
              },
              child: const Text('Accept Order'),
            ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
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


  /* ───────── MAIN BUILD ───────── */
  @override
  Widget build(BuildContext context) {
    final branchKey = branch.split(' (').first.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170CFE),
        title: const Text('Order Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('customer_orders')
            .where('branch',
            isGreaterThanOrEqualTo: branchKey,
            isLessThan: '$branchKey\uf8ff')
            .orderBy('branch')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          final processing = docs
              .where((d) =>
          (d.data()['status'] ?? '').toString().toLowerCase() ==
              'processing')
              .toList();

          final allPending = docs
              .where((d) => (d.data()['status'] ?? '').toString().toLowerCase() == 'pending')
              .toList();

          final rushPending = allPending.where((d) => d.data()['rushOrder'] == true).toList();
          final normalPending = allPending.where((d) => d.data()['rushOrder'] != true).toList();
          final pending = [...rushPending, ...normalPending]; // Rush at top

          List<Widget> buildCards(List<QueryDocumentSnapshot> list) {
            return list.map((d) {
              final m = d.data() as Map<String, dynamic>;
              final staff = (m['staffName'] ?? '').toString();
              final status = (m['status'] ?? '').toString().toLowerCase();
              final isRush = m['rushOrder'] == true;
              final isPending = status == 'pending';
              final isFree = staff.isEmpty;

              final List<TextSpan> staffSpan = [];

              // 'FREE' or staff name
              staffSpan.add(TextSpan(
                text: isFree ? 'FREE' : staff,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isFree ? const Color(0xFF04D26F) : Colors.black,
                ),
              ));

              // 'RUSH'
              if (isRush && isPending && isFree) {
                staffSpan.add(TextSpan(
                  text: ' • RUSH',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                  ),
                ));
              }

              return Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text('Order #${m['orderId'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 11),
                      children: [
                        const TextSpan(text: 'Assigned Staff: '),
                        ...staffSpan,
                        TextSpan(text: ' • ${status[0].toUpperCase()}${status.substring(1)}'),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showOrderDetails(context, d),
                ),
              );
            }).toList();
          }

          return (processing.isEmpty && pending.isEmpty)
              ? Center(
            child: Text(
              'No orders for $branchKey yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          )
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (processing.isNotEmpty) ...[
                const Text('Processing',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 8),
                ...buildCards(processing),
                const SizedBox(height: 20),
              ],
              if (pending.isNotEmpty) ...[
                const Text('Pending',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 8),
                ...buildCards(pending),
              ],
            ],
          );
        },
      ),
    );
  }
}
