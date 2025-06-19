// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;

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
/* ───────── PDF DOWNLOAD (no path_provider) ───────── */
  Future<void> _downloadInvoicePDF(Map<String, dynamic> data) async {
    try {
      /* 1. Build the PDF */
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context _) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Five-Stars Laundry | Staff Invoice',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Order #: ${data['orderId']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Status: ${data['status']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Assigned Staff Name: ${data['staffName']}'),
                pw.Text('Assigned Staff Contact: ${data['staffContact']}'),
                pw.SizedBox(height: 8),
                pw.Text('Customer: ${data['fullName']}'),
                pw.Text('Address: ${data['address']}'),
                pw.Text('Contact: ${data['contact']}'),
                pw.SizedBox(height: 8),
                pw.Text('Branch: ${data['branch']}'),
                pw.Text('Order Method: ${data['orderMethod']}'),
                pw.Text('Payment: ${data['paymentMethod']}'),
                pw.SizedBox(height: 10),
                pw.Text('Items:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...((data['items'] as List<dynamic>).map<pw.Widget>((item) {
                  final m = Map<String, dynamic>.from(item);
                  final laundry =
                      (m['typeOfLaundry'] as List?)?.join(', ') ?? '-';

                  /* bulky items handling */
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
                  final bulkyItems = bulkyMap.entries
                      .map((e) => '${e.key} - ${e.value}')
                      .join(', ');

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${m['serviceType'] ?? ''}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Regular Items: $laundry'),
                      pw.Text(
                          'Bulky Items: ${bulkyItems.isEmpty ? '-' : bulkyItems}'),
                      pw.Text(
                          'Personal Request: ${m['personalRequest']?.toString().isEmpty ?? true ? '-' : m['personalRequest']}'),
                      pw.Text('Item Total: ${m['totalPrice'] ?? 0} Pesos'),
                      pw.SizedBox(height: 8),
                    ],
                  );
                })),
                pw.Divider(),
                pw.Text('Grand Total: ${data['grandTotal']} Pesos',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            );
          },
        ),
      );

      /* 2. Choose a directory WITHOUT path_provider
       Common user-visible folder on Android: /storage/emulated/0/Download */
      final Directory dir = Directory('/storage/emulated/0/Download');

      if (!await dir.exists()) {
        await dir.create(recursive: true); // make sure it exists
      }

      /* 3. Write the PDF */
      final file = File('${dir.path}/invoice_${data['orderId']}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF04D26F),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 8),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Invoice saved to ${file.path}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE57373),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 8),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to save invoice. Device might not be compatible.',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
      print(e);
    }
  }

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
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('No'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF04D26F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return res == true;
  }

/* ───────── AUDIT helpers ───────── */
  void _promptAudit(DocumentSnapshot docSnap) {
    final data = docSnap.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ready to Release'),
        content: const Text(
          'Mark this order as reviewed and ready for delivery or pick-up?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.grey, foregroundColor: Colors.white),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF170CFE),
                foregroundColor: Colors.white),
            child: const Text('For Release Order'),
            onPressed: () async {
              await docSnap.reference.update({
                'isAudited': true,
                'status': 'For delivery/pick-up',
              });

              final invoiceRef = FirebaseFirestore.instance
                  .collection('customer_invoice')
                  .doc(docSnap.id);

              await invoiceRef.set({
                ...data,
                'isAudited': true,
                'status': 'For delivery/pick-up',
                'invoiceTimestamp': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              if (mounted) Navigator.pop(context); // close confirmation dialog
              if (mounted) Navigator.pop(context); // close order details

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF04D26F),
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
                          'Order marked as ready for delivery/pick-up!',
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
  void _showOrderDetails(DocumentSnapshot docSnap) async {
    final data = docSnap.data() as Map<String, dynamic>;
    final isCompleted =
        (data['status'] ?? '').toString().toLowerCase() == 'completed';
    final _showDownload =
        _isCompletedStatus(data['status'] ?? '') ||
            _isReadyStatus(data['status'] ?? '');

    final pricingSnapshot = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final Map<String, dynamic> pricingData = pricingSnapshot.data() ?? {};

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
              if (data['rushOrder'] == true)
                _detailRow('Rush Order', 'Yes (Complete Today)'),
              const SizedBox(height: 10),
              _detailRow('Staff', (data['staffName'] ?? '').toString().isEmpty ? '—' : data['staffName']),
              _detailRow('Staff Contact', (data['staffContact'] ?? '').toString().isEmpty ? '—' : data['staffContact']),
              const Divider(),
              _detailRow('Assigned Rider', '—'),
              _detailRow('Rider Contact', '—'),
              const SizedBox(height: 10),
              _detailRow('Customer', data['fullName']),
              _detailRow('Customer Address', data['address']),
              _detailRow('Contact', data['contact']),
              const Divider(),
              _detailRow('Order Method', data['orderMethod']),
              _detailRow('Payment', data['paymentMethod']),
              const Divider(),
              ...(data['items'] as List<dynamic>).map((item) {
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
              if ((data['preferredDetergents'] ?? []).isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Preferred Detergents / Softeners:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                ...data['preferredDetergents'].map<Widget>((d) {
                  if (d is Map<String, dynamic>) {
                    final name = d['label'] ?? d['price'] ?? 'Unnamed';
                    final rawPrice = d['pricingPerLoad'] ?? d['price'] ?? 0;
                    final price = rawPrice is int ? rawPrice.toDouble() : rawPrice;

                    int multiplier = 1;
                    if ((data['items'] as List).isNotEmpty) {
                      multiplier = (data['items'] as List)
                          .where((item) {
                        final type = (item['serviceType'] ?? '').toString().toLowerCase();
                        return type == 'wash cleaning' || type == 'wash, dry & press';
                      })
                          .length;
                    }

                    final bool isMulti = (data['items'] as List).length > 1 && multiplier > 1;
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
              if (data['isAudited'] != true)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Please review the final weight to confirm the accurate weight and final price of customer items.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: data['isAudited'] == true
                              ? Colors.grey
                              : const Color(0xFF170CFE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          data['isAudited'] == true ? 'Reviewed' : 'Review',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed:
                        data['isAudited'] == true ? null : () => _promptAudit(docSnap),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isReadyStatus(data['status'] ?? '') && !isCompleted)
                      Flexible(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                            isCompleted ? Colors.grey : const Color(0xFF04D26F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Completed',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: isCompleted
                              ? null
                              : () async {
                            if (!await _confirmCompletion(context)) return;

                            await docSnap.reference.update({
                              'status': 'completed',
                              'completionTimestamp': FieldValue.serverTimestamp(),
                            });

                            final invoiceRef = FirebaseFirestore.instance
                                .collection('customer_invoice')
                                .doc(docSnap.id);

                            await invoiceRef.set({
                              ...data,
                              'status': 'completed',
                              'completionTimestamp': FieldValue.serverTimestamp(),
                              'invoiceTimestamp': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            if (mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF04D26F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 4),
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle_outline,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Order marked as completed!',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (_isReadyStatus(data['status'] ?? '') && !isCompleted)
                      const SizedBox(width: 8),
                    Flexible(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Close',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_showDownload)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF170CFE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Download'),
                      onPressed: () => _downloadInvoicePDF(data),
                    ),
                  ),
              ],
            ),
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
                        reverseTransitionDuration: Duration.zero),
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
            BottomNavigationBarItem(
                icon: Icon(Icons.logout), label: 'Logout'),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF170CFE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shopping_basket,
                        color: Colors.white, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Your Laundry Basket',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
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
                      return Center(
                          child: Text('Your basket is empty.',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[700])));
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('• Completed laundry orders',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ));

                    if (completedDocs.isEmpty) {
                      children.add(const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('No completed orders yet.'),
                      ));
                    } else {
                      children.addAll(completedDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 12),
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
                            onTap: () => _showOrderDetails(doc),
                          ),
                        );
                      }));
                    }

                    /* ───────── Section 2 – Ready to deliver / pick-up ───────── */
                    children.add(const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('• Ready to deliver / for customer pick-up',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ));

                    if (readyDocs.isEmpty) {
                      children.add(const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('No orders are ready yet.'),
                      ));
                    } else {
                      children.addAll(readyDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 12),
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
                            onTap: () => _showOrderDetails(doc),
                          ),
                        );
                      }));
                    }

                    /* ───────── Section 3 – Processing ───────── */
                    children.add(const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('• Processing',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ));

                    if (processingDocs.isEmpty) {
                      children.add(const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('No orders are currently processing.'),
                      ));
                    } else {
                      children.addAll(processingDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 12),
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
