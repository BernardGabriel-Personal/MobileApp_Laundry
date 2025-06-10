import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '9_customer_orderingPage.dart';

class dryCleaningPage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const dryCleaningPage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<dryCleaningPage> createState() => _dryCleaningPageState();
}

class _dryCleaningPageState extends State<dryCleaningPage> {
  // ────────────────────────────── DATA SOURCES ──────────────────────────────
  final List<String> regularLaundryTypes = [
    'Regular Clothes',
    'Thick Clothes',
    'Delicates',
  ];
  final Map<String, String> laundryTypeDescriptions = {
    'Regular Clothes': 'Cotton, Linen, Polyester, Rayon, Nylon, Spandex, Uniforms, Athletic Wear, etc',
    'Thick Clothes': 'Wool, Velvet, Jacket, Denim, Jeans, etc',
    'Delicates': 'Silk, Lingerie, Baby Clothes, etc',
  };


  final List<String> beddingItems = [
    'Beddings',
    'Curtains',
    'Blanket',
    'Comforter',
    'Fleece',
    'Quilt',
    'Gown',
    'Suit'
  ];

  // ────────────────────────────── STATE MAPS ──────────────────────────────
  late final Map<String, bool> selectedRegularLaundryTypes;
  late final Map<String, bool> selectedBeddingItems;
  late final Map<String, int> beddingQuantities;

  bool othersSelected = false;
  String othersText = '';
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRegularLaundryTypes = {for (var t in regularLaundryTypes) t: false};
    selectedBeddingItems = {for (var i in beddingItems) i: false};
    beddingQuantities = {for (var i in beddingItems) i: 1};
  }

  // ────────────────────────────── HELPERS ──────────────────────────────
  double _getSelectedBeddingTotal(double unitPrice) {
    double total = 0;
    selectedBeddingItems.forEach((item, selected) {
      if (selected) total += (beddingQuantities[item] ?? 0) * unitPrice;
    });
    return total;
  }

  bool _hasAnySelection({
    required List<String> laundry,
    required Map<String, int> bulky,
  }) {
    return laundry.isNotEmpty || bulky.isNotEmpty;
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: const Color(0xFFE57373), size: 28),
            SizedBox(width: 10),
            Text('Nothing selected', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Please pick at least one regular laundry type or bulky item before continuing.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────── UI BUILD ──────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04D26F),
        title: const Text(
          'Dry Cleaning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
            _buildRegularLaundrySection(),
            const SizedBox(height: 20),
            _buildBeddingSection(),
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

  // ────────────────────────────── WIDGETS ──────────────────────────────
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
            const Icon(Icons.dry_cleaning,
                size: 50, color: const Color(0xFF170CFE)),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dry Cleaning',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF170CFE),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Professional dry cleaning service for delicate garments. Gentle care with free fold included.',
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

  // ───────────────────────── PRICING SECTION ─────────────────────────
  Widget _buildPricingSection() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pricing_management')
          .doc('pricing')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!.data() ?? {};
        final double dryBase =
            double.tryParse(data['dry']?.toString() ?? '0') ?? 0;
        final double singleQueenUnit =
            double.tryParse(data['singleQueen']?.toString() ?? '0') ?? 0;
        final String dryNote = data['dryNote']?.toString() ?? '';

        final bool hasRegular = selectedRegularLaundryTypes.values.any((v) => v) ||
            (othersSelected && othersText.trim().isNotEmpty);

        final double bulkyTotal = _getSelectedBeddingTotal(singleQueenUnit);
        final double total = bulkyTotal + (hasRegular ? dryBase : 0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'TOTAL = ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: '₱ ${total.toStringAsFixed(2)}',
                        ),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dryNote,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegularLaundrySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Type Of Laundry',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Scrollbar(
                child: ListView(
                  children: [
                    ...regularLaundryTypes.map((type) {
                      return _miniCheckboxTile(
                        label: type,
                        value: selectedRegularLaundryTypes[type],
                        onChanged: (val) {
                          setState(() {
                            selectedRegularLaundryTypes[type] = val ?? false;
                          });
                        },
                        subNote: laundryTypeDescriptions[type], // shows sub note
                      );
                    }).toList(),
                    _miniCheckboxTile(
                      label: 'Others',
                      value: othersSelected,
                      onChanged: (val) {
                        setState(() {
                          othersSelected = val ?? false;
                          if (!othersSelected) othersText = '';
                        });
                      },
                    ),
                    if (othersSelected)
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 40, top: 4, bottom: 8),
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

  Widget _buildBeddingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('pricing_management')
              .doc('pricing')
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final double singleQueenUnit =
                double.tryParse(data['singleQueen']?.toString() ?? '0') ?? 0;
            final singleQueenText = data['singleQueen'] != null
                ? data['singleQueen'].toString()
                : '—';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Single/Queen Size Bulky Items = ₱$singleQueenText per-piece',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...beddingItems.map(
                      (item) => Column(
                    children: [
                      _miniCheckboxTile(
                        label: item,
                        value: selectedBeddingItems[item],
                        onChanged: (val) {
                          setState(() {
                            selectedBeddingItems[item] = val ?? false;
                            if (val == true && beddingQuantities[item] == 0) {
                              beddingQuantities[item] = 1;
                            }
                          });
                        },
                      ),
                      if (selectedBeddingItems[item] == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (beddingQuantities[item]! > 1) {
                                      beddingQuantities[item] =
                                          beddingQuantities[item]! - 1;
                                    }
                                  });
                                },
                              ),
                              Text(
                                beddingQuantities[item].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    beddingQuantities[item] =
                                        beddingQuantities[item]! + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selected bulky items total: ₱${_getSelectedBeddingTotal(singleQueenUnit).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

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
              hintText: 'e.g., Handle with care, delicate fabric, etc',
              filled: true,
              fillColor: Colors.grey[200],
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: const Color(0xFF04D26F)),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Finalized pricing will be shown in your invoice after weighing at our shop. '
                'Extra charges may apply for over-sized, delicate, or special-care items.',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              label: const Text(
                'Add to Cart',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleOrderNow,           // ← NEW
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04D26F),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Order Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── ORDER NOW FLOW ───────────────────────────
  Future<void> _handleOrderNow() async {
    // 1. Pull latest pricing so totals are correct.
    final pricingSnap = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final pricing = pricingSnap.data() ?? {};
    final double dryBase =
        double.tryParse(pricing['dry']?.toString() ?? '0') ?? 0;
    final double singleQueenUnit =
        double.tryParse(pricing['singleQueen']?.toString() ?? '0') ?? 0;

    // 2. Gather selections.
    final List<String> typeOfLaundry = selectedRegularLaundryTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (othersSelected && othersText.trim().isNotEmpty) {
      typeOfLaundry.add('Others: ${othersText.trim()}');
    }

    final Map<String, int> bulkyCounts = {};
    selectedBeddingItems.forEach((item, selected) {
      if (selected) bulkyCounts[item] = beddingQuantities[item]!;
    });

    // 3. Validate.
    if (!_hasAnySelection(laundry: typeOfLaundry, bulky: bulkyCounts)) {
      _showValidationDialog();
      return;
    }

    // 4. Compute totals.
    final double priceOfBulkyItems = bulkyCounts.entries.fold<double>(
        0.0, (sum, e) => sum + (e.value * singleQueenUnit));
    final double totalPrice =
        priceOfBulkyItems + (typeOfLaundry.isNotEmpty ? dryBase : 0);

    // 5. Navigate to summary page (no DB write).
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderingPage(
          fullName: widget.fullName,
          address: widget.address,
          email: widget.email,
          contact: widget.contact,
          serviceType: 'Dry Cleaning',
          typeOfLaundry: typeOfLaundry,
          bulkyItems: bulkyCounts,
          dryBase: dryBase,
          priceOfBulkyItems: priceOfBulkyItems,
          totalPrice: totalPrice,
          personalRequest: noteController.text.trim(),
        ),
      ),
    );
  }

  // ─────────────────────────── FIRESTORE ADD TO CART ───────────────────────────
  Future<void> _handleAddToCart() async {
    // 1. Pull latest pricing so we compute with current values.
    final pricingSnap = await FirebaseFirestore.instance
        .collection('pricing_management')
        .doc('pricing')
        .get();
    final pricing = pricingSnap.data() ?? {};
    final double dryBase =
        double.tryParse(pricing['dry']?.toString() ?? '0') ?? 0;
    final double singleQueenUnit =
        double.tryParse(pricing['singleQueen']?.toString() ?? '0') ?? 0;

    // 2. Gather selections.
    final List<String> typeOfLaundry = selectedRegularLaundryTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (othersSelected && othersText.trim().isNotEmpty) {
      typeOfLaundry.add('Others: ${othersText.trim()}');
    }

    final Map<String, int> bulkyCounts = {};
    selectedBeddingItems.forEach((item, selected) {
      if (selected) bulkyCounts[item] = beddingQuantities[item]!;
    });

    // 3. Early validation check.
    if (!_hasAnySelection(laundry: typeOfLaundry, bulky: bulkyCounts)) {
      _showValidationDialog();
      return; // stop here if nothing was selected
    }

    // 4. Compute totals.
    final double priceOfBulkyItems = bulkyCounts.entries.fold<double>(
        0, (sum, e) => sum + (e.value * singleQueenUnit));
    final double totalPrice =
        priceOfBulkyItems + (typeOfLaundry.isNotEmpty ? dryBase : 0);

    // 5. Write to Firestore.
    try {
      await FirebaseFirestore.instance.collection('cart_customers').add({
        'email': widget.email,
        'contact': widget.contact,
        'serviceType': 'Dry Cleaning',
        'typeOfLaundry': typeOfLaundry,
        'bulkyItems': bulkyCounts.keys.toList(),
        'numberOfBulkyItems': bulkyCounts,
        'priceOfBulkyItems': priceOfBulkyItems,
        'personalRequest': noteController.text.trim(),
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF04D26F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Added to cart!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unable to add to cart: $e',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ───────────────────────── SMALL HELPERS ─────────────────────────
  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.grey),
  );

  Widget _miniCheckboxTile({
    required String label,
    String? subNote, // NEW
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF04D26F),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          value: value,
          onChanged: onChanged,
        ),
        if (subNote != null)
          Padding(
            padding: const EdgeInsets.only(left: 48.0, bottom: 0), // align with checkbox
            child: Text(
              subNote,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
