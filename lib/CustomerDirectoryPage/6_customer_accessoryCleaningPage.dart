import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '9_customer_orderingPage.dart';

class accessoryCleaningPage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const accessoryCleaningPage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<accessoryCleaningPage> createState() => _accessoryCleaningPageState();
}

class _accessoryCleaningPageState extends State<accessoryCleaningPage> {
/* ─────────────────────────  DATA  ───────────────────────── */
  final List<String> accessoryItems = ['Shoes', 'Bag', 'Helmet'];

  late final Map<String, bool> selectedAccessory;
  late final Map<String, int> accessoryQuantity;

  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedAccessory = {for (var i in accessoryItems) i: false};
    accessoryQuantity = {for (var i in accessoryItems) i: 1};
  }

/* ─────────────────────────  HELPERS  ───────────────────────── */
  double _getSelectedTotal(double unitPrice) {
    double total = 0;
    selectedAccessory.forEach((item, sel) {
      if (sel) total += (accessoryQuantity[item] ?? 0) * unitPrice;
    });
    return total;
  }

  bool _hasAnySelection(Map<String, int> counts) => counts.isNotEmpty;

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Color(0xFFE57373), size: 28),
            SizedBox(width: 10),
            Text('Nothing selected', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Please pick at least one item before continuing.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

/* ─────────────────────────  UI  ───────────────────────── */
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFECF0F3),
    appBar: AppBar(
      backgroundColor: const Color(0xFF04D26F),
      title: const Text('Accessory Cleaning',
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeaderCard(),
          const SizedBox(height: 20),
          _buildPricingSection(),
          const SizedBox(height: 25),
          _buildAccessorySection(),
          const SizedBox(height: 16),
          _buildPersonalNote(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

/* ---------- HEADER ---------- */
  Widget _buildHeaderCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cleaning_services_outlined,
              size: 50, color: Color(0xFF170CFE)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accessory Cleaning',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF170CFE))),
                SizedBox(height: 4),
                Text(
                  'Professional cleaning for shoes, bags, and helmets.',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

/* ---------- PRICING ---------- */
  Widget _buildPricingSection() => StreamBuilder<
      DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .snapshots(),
    builder: (_, snap) {
      if (!snap.hasData) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(),
        );
      }

      final data = snap.data!.data() ?? {};
      final double unitPrice =
          double.tryParse(data['shoesBagHelmet']?.toString() ?? '0') ?? 0;
      final note = data['shoesBagHelmetNote']?.toString() ?? '';

      final total = _getSelectedTotal(unitPrice);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('TOTAL = ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                Expanded(
                  child: IgnorePointer(
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: '₱ ${total.toStringAsFixed(2)}'),
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(note,
                style:
                const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    },
  );

/* ---------- ACCESSORY SECTION ---------- */
  Widget _buildAccessorySection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('pricing_management')
            .doc('pricing')
            .snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? {};
          final double unit =
              double.tryParse(data['shoesBagHelmet']?.toString() ?? '0') ??
                  0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shoes / Bag / Helmet = ₱${unit.toStringAsFixed(0)} per piece',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...accessoryItems.map((item) => Column(
                children: [
                  _miniCheckboxTile(
                      label: item,
                      value: selectedAccessory[item],
                      onChanged: (v) {
                        setState(() {
                          selectedAccessory[item] = v ?? false;
                          if (v == true &&
                              accessoryQuantity[item] == 0) {
                            accessoryQuantity[item] = 1;
                          }
                        });
                      }),
                  if (selectedAccessory[item] == true)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 40, bottom: 8),
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(
                                  Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (accessoryQuantity[item]! > 1) {
                                    accessoryQuantity[item] =
                                        accessoryQuantity[item]! - 1;
                                  }
                                });
                              }),
                          Text(accessoryQuantity[item].toString(),
                              style:
                              const TextStyle(fontSize: 16)),
                          IconButton(
                              icon: const Icon(
                                  Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  accessoryQuantity[item] =
                                      accessoryQuantity[item]! + 1;
                                });
                              }),
                        ],
                      ),
                    ),
                ],
              )),
              const SizedBox(height: 4),
              Text(
                  'Selected items total: ₱${_getSelectedTotal(unit).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
            ],
          );
        },
      ),
    ),
  );

/* ---------- PERSONAL REQUEST ---------- */
  Widget _buildPersonalNote() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: 'Personalized Request',
            hintText: 'e.g., Deodorize shoes, gentle handling, etc.',
            filled: true,
            fillColor: Colors.grey[200],
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF04D26F)),
                borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Finalized pricing appears on your invoice after inspection. '
              'Extra charges may apply for oversized or special-care items.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4),
        ),
      ],
    ),
  );

/* ---------- BUTTONS ---------- */
  Widget _buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleAddToCart,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            label: const Text('Add to Cart',
                style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleOrderNow,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04D26F),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Order Now',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );

/* ─────────────────────────  ADD-TO-CART  ───────────────────────── */
  Future<void> _handleAddToCart() async {
    final priceSnap = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final double unitPrice =
        double.tryParse(priceSnap.data()?['shoesBagHelmet']?.toString() ?? '0') ??
            0;

    final counts = _gatherCounts();
    if (!_hasAnySelection(counts)) {
      _showValidationDialog();
      return;
    }

    final double totalPrice =
    counts.entries.fold(0, (s, e) => s + (e.value * unitPrice));

    try {
      await FirebaseFirestore.instance.collection('cart_customers').add({
        'email': widget.email,
        'contact': widget.contact,
        'serviceType': 'Accessory Cleaning',
        'typeOfLaundry': [],
        'bulkyItems': counts.keys.toList(),
        'numberOfBulkyItems': counts,
        'priceOfBulkyItems': totalPrice,
        'personalRequest': noteController.text.trim(),
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
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
                child: Text('Added to cart!',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE57373),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Unable to add to cart: $e',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

/* ─────────────────────────  ORDER NOW  ───────────────────────── */
  Future<void> _handleOrderNow() async {
    final priceSnap = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final double unitPrice =
        double.tryParse(priceSnap.data()?['shoesBagHelmet']?.toString() ?? '0') ??
            0;

    final counts = _gatherCounts();
    if (!_hasAnySelection(counts)) {
      _showValidationDialog();
      return;
    }

    final double totalPrice =
    counts.entries.fold(0, (s, e) => s + (e.value * unitPrice));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderingPage(
          fullName: widget.fullName,
          address: widget.address,
          email: widget.email,
          contact: widget.contact,
          serviceType: 'Accessory Cleaning',
          typeOfLaundry: const [],
          bulkyItems: counts,
          washBase: 0,                // no base charge
          priceOfBulkyItems: totalPrice,
          totalPrice: totalPrice,
          personalRequest: noteController.text.trim(),
        ),
      ),
    );
  }

/* ─────────────────────────  INTERNAL  ───────────────────────── */
  Map<String, int> _gatherCounts() {
    final Map<String, int> counts = {};
    selectedAccessory.forEach((item, sel) {
      if (sel) counts[item] = accessoryQuantity[item]!;
    });
    return counts;
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.grey),
  );

  Widget _miniCheckboxTile({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) =>
      CheckboxListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color(0xFF04D26F),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
      );
}
