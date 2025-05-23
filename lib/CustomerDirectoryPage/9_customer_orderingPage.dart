import 'package:flutter/material.dart';

class OrderingPage extends StatelessWidget {
  // ───────────────────────── USER & ORDER INFO ─────────────────────────
  final String fullName;
  final String address;
  final String email;
  final String contact;

  final String serviceType;
  final List<String> typeOfLaundry;           // Regular laundry selections
  final Map<String, int> bulkyItems;          // { itemName : quantity }
  final double? washBase;                     // Provided by Wash-Cleaning page
  final double? dryBase;                    // Provided by Dry-Cleaning page
  final double priceOfBulkyItems;             // Total price of bulky items
  final double totalPrice;                    // Grand total
  final String personalRequest;               // Note / special instructions

  const OrderingPage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
    required this.serviceType,
    required this.typeOfLaundry,
    required this.bulkyItems,
    this.dryBase,                            // optional, but one of the two…
    this.washBase,
    required this.priceOfBulkyItems,
    required this.totalPrice,
    required this.personalRequest,
  })  : assert(
  dryBase != null || washBase != null,
  'Either basePrice or washBase must be provided.'),
        super(key: key);

  // Convenient getter to unify whichever price was passed.
  double get _base => dryBase ?? washBase ?? 0;

  // ───────────────────────── BUILD ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04D26F),
        title: const Text(
          'Order Summary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _summaryHeader(),
            const SizedBox(height: 20),
            _sectionCard(
              title: 'Service Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Service', serviceType),
                  _infoRow('Base Price', '₱ ${_base.toStringAsFixed(2)}'),
                  _infoRow('Bulky Items Price',
                      '₱ ${priceOfBulkyItems.toStringAsFixed(2)}'),
                  const Divider(),
                  _infoRow('Total', '₱ ${totalPrice.toStringAsFixed(2)}',
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Regular Laundry',
              child: typeOfLaundry.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: typeOfLaundry
                    .map((t) => Text('• $t'))
                    .toList(growable: false),
              )
                  : const Text('None selected'),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Bulky Items',
              child: bulkyItems.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bulkyItems.entries
                    .map((e) => Text(
                    '• ${e.key} – ${e.value} pc${e.value > 1 ? 's' : ''}'))
                    .toList(growable: false),
              )
                  : const Text('None selected'),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Personalized Request',
              child: Text(
                personalRequest.isNotEmpty ? personalRequest : '—',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            _placeOrderButton(context),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── WIDGET HELPERS ─────────────────────────
  Widget _summaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email),
          Text(contact),
          const SizedBox(height: 4),
          Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
              TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04D26F),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF04D26F),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Order placed! (Demo)',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.shopping_bag, color: Colors.white),
        label: const Text('Place Order', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
