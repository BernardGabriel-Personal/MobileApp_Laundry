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

  /* ───────── Re-usable text helpers ───────── */
  Widget _detailRow(String label, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Expanded(child: Text('$value')),
      ],
    ),
  );

  Widget _miniRow(String label, dynamic value,
      {bool bold = false, bool wrap = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ',
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
            Expanded(
                child: Text('$value',
                    overflow:
                    wrap ? TextOverflow.visible : TextOverflow.ellipsis)),
          ],
        ),
      );

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
  void _showOrderDetails(
      BuildContext ctx, QueryDocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

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
              _detailRow('Staff',
                  (data['staffName'] ?? '').toString().isEmpty ? '—' : data['staffName']),
              _detailRow('Staff Contact',
                  (data['staffContact'] ?? '').toString().isEmpty ? '—' : data['staffContact']),
              _detailRow('Customer', data['fullName']),
              _detailRow('Customer Address', data['address']),
              _detailRow('Contact', data['contact']),
              const Divider(),
              _detailRow('Order Method', data['orderMethod']),
              _detailRow('Payment', data['paymentMethod']),
              _detailRow(
                'Preferred Detergents',
                (data['preferredDetergents'] as List<dynamic>?)
                    ?.join(', ')
                    .trim()
                    .isNotEmpty ==
                    true
                    ? (data['preferredDetergents'] as List).join(', ')
                    : '—',
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
                      'Final pricing must be calculated after weighing the customer items and including any delivery or pick-up fees.',
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
                final bulky = bulkyMap.isEmpty
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
                      _miniRow('Regular Items',
                          laundry.isEmpty ? '—' : laundry),
                      _miniRow('Bulky / Accessory',
                          bulky.isEmpty ? '—' : bulky),
                      _miniRow('Personal Request',
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
        actionsPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        actions: [
          if ((data['status'] ?? '').toString().toLowerCase() == 'pending')
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF170CFE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Accept Order'),
              onPressed: () async {
                if (!await _confirmAccept(ctx)) return;
                try {
                  await snap.reference.update({
                    'status': 'processing',
                    'staffName': fullName,
                    'staffContact': contact,
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Center(child: Text('Order accepted!')),
                    backgroundColor: Color(0xFF170CFE),
                    behavior: SnackBarBehavior.floating,
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Failed to accept order: $e'),
                    backgroundColor: Colors.redAccent,
                  ));
                }
              },
            ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

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
          final pending = docs
              .where((d) =>
          (d.data()['status'] ?? '').toString().toLowerCase() ==
              'pending')
              .toList();

          List<Widget> buildCards(List<QueryDocumentSnapshot> list) {
            return list.map((d) {
              final m = d.data() as Map<String, dynamic>;
              final staff = (m['staffName'] ?? '').toString();
              final status = (m['status'] ?? '').toString();

              return Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text('Order #${m['orderId'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 11),
                      children: [
                        const TextSpan(text: 'Assigned Staff: '),
                        TextSpan(
                          text: staff.isEmpty ? 'FREE' : staff,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: staff.isEmpty
                                ? const Color(0xFF04D26F)
                                : Colors.black,
                          ),
                        ),
                        TextSpan(text: ' • $status'),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showOrderDetails(context, d),
                ),
              );
            }).toList();
          }

          return docs.isEmpty
              ? Center(
              child: Text('No orders for $branchKey yet.',
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey[700])))
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
