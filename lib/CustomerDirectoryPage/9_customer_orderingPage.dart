import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderingPage extends StatelessWidget {
  /* ───────── USER INFO (always required) ───────── */
  final String fullName;
  final String address;
  final String email;
  final String contact;

  /* ───────── SINGLE-SERVICE FIELDS (optional) ───────── */
  final String? serviceType;                 // one service
  final List<String>? typeOfLaundry;         // regular items
  final Map<String, int>? bulkyItems;        // bulky / accessories
  final double? washBase;
  final double? dryBase;
  final double? priceOfBulkyItems;           // subtotal of bulky
  final String? personalRequest;

  /* ───────── MULTI-SERVICE (cart checkout) ───────── */
  final List<QueryDocumentSnapshot>? selectedItems;
  final double totalPrice;

  OrderingPage({
    Key? key,
    /* user info */
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
    /* single-service params  */
    this.serviceType,
    this.typeOfLaundry,
    this.bulkyItems,
    this.washBase,
    this.dryBase,
    this.priceOfBulkyItems,
    this.personalRequest,
    /* multi-service params  */
    this.selectedItems,
    /* mandatory grand total */
    required this.totalPrice,
  })  : assert(
  (selectedItems != null && selectedItems.isNotEmpty) ||
      (serviceType != null),
  'Either selectedItems or serviceType must be supplied',
  ),
        super(key: key);

  /* ───────── helpers for SINGLE service ───────── */
  double get _singleBase {
    if (typeOfLaundry == null || typeOfLaundry!.isEmpty) return 0;
    return washBase ?? dryBase ?? 0;
  }

  bool get _isMultiOrder =>
      selectedItems != null && selectedItems!.isNotEmpty;

  /* ───────── BUILD ───────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04D26F),
        title: const Text('Order Summary',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _summaryHeader(),
            const SizedBox(height: 20),

            /* ================= SERVICE DETAILS ================= */
            if (_isMultiOrder)
              _multiServiceCard()
            else
              _singleServiceCard(),

            const SizedBox(height: 30),
            _placeOrderButton(context),
          ],
        ),
      ),
    );
  }

  /* ─────────  HEADER WITH USER INFO ───────── */
  Widget _summaryHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('• $email'),
              const SizedBox(height: 4),
              Text('• $contact'),
              const SizedBox(height: 4),
              Text('• $address',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Icon(Icons.person, color: Colors.black54, size: 75),
      ],
    ),
  );

  /* ─────────  SINGLE-SERVICE CARD ───────── */
  Widget _singleServiceCard() => _sectionCard(
    title: 'Service Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Service', serviceType ?? ''),
        _infoRow('Base Price', '₱ ${_singleBase.toStringAsFixed(2)}'),
        _infoRow(
            'Bulky / Accessory Price',
            '₱ ${(priceOfBulkyItems ?? 0).toStringAsFixed(2)}'),
        const Divider(),
        _infoRow('Total', '₱ ${totalPrice.toStringAsFixed(2)}',
            bold: true),
        const SizedBox(height: 12),
        _infoRow('Regular Laundry Items',
            (typeOfLaundry != null && typeOfLaundry!.isNotEmpty)
                ? typeOfLaundry!.join(', ')
                : 'None'),
        _infoRow(
            'Bulky / Accessories',
            (bulkyItems != null && bulkyItems!.isNotEmpty)
                ? bulkyItems!.entries
                .map((e) =>
            '${e.key} – ${e.value} pc${e.value > 1 ? 's' : ''}')
                .join(', ')
                : 'None'),
        const SizedBox(height: 12),
        _infoRow('Personalized Request',
            personalRequest?.isNotEmpty == true
                ? personalRequest!
                : '—'),
      ],
    ),
  );

  /* ─────────  MULTI-SERVICE CARD ───────── */
  Widget _multiServiceCard() => _sectionCard(
    title: 'Selected Services',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1) one detailed block per selected doc
        ...selectedItems!.map(_buildServiceDetail).toList(),
        // 2) grand total at the bottom
        const Divider(height: 32),
        _infoRow('Grand Total', '₱ ${totalPrice.toStringAsFixed(2)}', bold: true),
      ],
    ),
  );

/* Builds the full detail for *one* service */
  Widget _buildServiceDetail(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final svc         = d['serviceType']            ?? 'Service';
    final regItems    = (d['typeOfLaundry']         as List?)?.cast<String>() ?? [];
    final bulkyMap    = (d['numberOfBulkyItems']    as Map?) ?.cast<String, dynamic>() ?? {};
    final base        = (d['washBase'] ?? d['dryBase'] ?? 0).toDouble();
    final bulkyPrice  = (d['priceOfBulkyItems']     ?? 0).toDouble();
    final total       = (d['totalPrice']            ?? 0).toDouble();
    final personal    = (d['personalRequest']       ?? '').toString();

    String _fmtBulky(Map<String, dynamic> m) =>
        m.isEmpty ? 'None'
            : m.entries.map((e) => '${e.key} – ${e.value} pc${e.value > 1 ? "s" : ""}').join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── headline row (name + subtotal) ──
          Row(
            children: [
              Expanded(child: Text('• $svc', style: const TextStyle(fontWeight: FontWeight.bold))),
              Text('₱ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          // ── detail rows (reuse your helper) ──
          _infoRow('Base Price',                '₱ ${base.toStringAsFixed(2)}'),
          _infoRow('Bulky / Accessory Price',   '₱ ${bulkyPrice.toStringAsFixed(2)}'),
          _infoRow('Regular Laundry Items',     regItems.isNotEmpty ? regItems.join(', ') : 'None'),
          _infoRow('Bulky / Accessories',       _fmtBulky(bulkyMap)),
          _infoRow('Personalized Request',      personal.isNotEmpty ? personal : '—'),
          const Divider(height: 24),            // separator between services
        ],
      ),
    );
  }


  /* ─────────  GENERIC BUILDING BLOCKS ───────── */
  Widget _sectionCard({required String title, required Widget child}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );

  Widget _infoRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text('$label: ',
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight:
                  bold ? FontWeight.bold : FontWeight.w400)),
        ),
      ],
    ),
  );

  /* ─────────  PLACE ORDER (demo) ───────── */
  Widget _placeOrderButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF04D26F),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF04D26F),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Order placed! (Demo)',
                      style:
                      TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: const Icon(Icons.shopping_bag, color: Colors.white),
      label:
      const Text('Place Order', style: TextStyle(color: Colors.white)),
    ),
  );
}
