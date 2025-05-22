import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ironingPage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const ironingPage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<ironingPage> createState() => _ironingPageState();
}

class _ironingPageState extends State<ironingPage> {
  // ───────────────── DATA SOURCES ─────────────────
  final List<String> itemTypes = [
    'Cotton', 'Linen', 'Polyester', 'Silk', 'Wool', 'Rayon', 'Nylon', 'Spandex', 'Denim', 'Velvet', 'Suits', 'Dress Shirts', 'Gowns / Dresses', 'Uniforms', 'Baby Clothes', 'Delicates / Lingerie', 'Athletic Wear', 'Beddings', 'Curtains', 'Blanket', 'Comforter', 'Fleece', 'Quilt',
  ];

  late final Map<String, bool> selectedItems;
  bool othersSelected = false;
  String othersText = '';
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedItems = {for (var t in itemTypes) t: false};
  }

  // ───────────────── HELPERS ─────────────────
  bool _hasAnySelection(List<String> items) => items.isNotEmpty;

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
          'Please pick at least one item before adding to cart.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ───────────────── UI BUILD ─────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04D26F),
        title: const Text('Iron / Press Service',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            _buildItemSection(),
            const SizedBox(height: 16),
            _buildCarefulNoteField(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ───────── Header ─────────
  Widget _buildHeaderCard() {
    return Padding(
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
            const Icon(Icons.iron, // use iron icon if on Material 3; fallback:
                size: 50, color: Color(0xFF170CFE)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Iron / Press Service',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF170CFE))),
                  SizedBox(height: 4),
                  Text(
                    'Professional ironing and pressing for your garments.',
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Pricing ─────────
  Widget _buildPricingSection() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
        final double pressPrice =
            double.tryParse(data['pressOnly']?.toString() ?? '0') ?? 0;
        final pressNote = data['pressNote']?.toString() ?? '';

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
                        controller:
                        TextEditingController(text: '₱ ${pressPrice.toStringAsFixed(2)}'),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(pressNote,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        );
      },
    );
  }

  // ───────── Items (no bulky section) ─────────
  Widget _buildItemSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Type Of Item To Press/Iron',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: Scrollbar(
                child: ListView(
                  children: [
                    ...itemTypes.map((type) => _miniCheckboxTile(
                      label: type,
                      value: selectedItems[type],
                      onChanged: (v) =>
                          setState(() => selectedItems[type] = v ?? false),
                    )),
                    _miniCheckboxTile(
                      label: 'Others',
                      value: othersSelected,
                      onChanged: (v) {
                        setState(() {
                          othersSelected = v ?? false;
                          if (!othersSelected) othersText = '';
                        });
                      },
                    ),
                    if (othersSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, top: 4, bottom: 8),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Please specify',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          onChanged: (val) => setState(() => othersText = val),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Personalized note ─────────
  Widget _buildCarefulNoteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: 'Personalized Request',
              hintText: 'e.g., Light starch only, etc',
              filled: true,
              fillColor: Colors.grey[200],
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF04D26F)),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Finalized pricing will be shown in your invoice after weighing at our shop. Extra charges may apply for over-sized, delicate, or special-care items.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Buttons ─────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              label:
              const Text('Add to Cart', style: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {/* optional order-now flow */},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04D26F),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Order Now', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Add-to-cart logic ─────────
  Future<void> _handleAddToCart() async {
    final priceSnap = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final double pressPrice =
        double.tryParse(priceSnap.data()?['pressOnly']?.toString() ?? '0') ?? 0;

    final List<String> items = selectedItems.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (othersSelected && othersText.trim().isNotEmpty) {
      items.add('Others: ${othersText.trim()}');
    }

    if (!_hasAnySelection(items)) {
      _showValidationDialog();
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('cart_customers').add({
        'email': widget.email,
        'contact': widget.contact,
        'serviceType': 'Iron Pressing',
        'typeOfLaundry': items,
        'pressOnlyPrice': pressPrice,
        'personalRequest': noteController.text.trim(),
        'totalPrice': pressPrice,
        'bulkyItems': [],             // Blank holder
        'numberOfBulkyItems': {},     // Blank Holder
        'priceOfBulkyItems': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF04D26F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFE57373),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Unable to add to cart: $e',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ───────── Reusable helpers ─────────
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
