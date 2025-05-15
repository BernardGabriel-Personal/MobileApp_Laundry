import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class washCleaningPage extends StatefulWidget {
  const washCleaningPage({Key? key}) : super(key: key);

  @override
  State<washCleaningPage> createState() => _washCleaningPageState();
}

class _washCleaningPageState extends State<washCleaningPage> {
  final List<String> regularLaundryTypes = [
    'Cotton',
    'Linen',
    'Polyester',
    'Silk',
    'Wool',
    'Rayon',
    'Nylon',
    'Spandex',
    'Denim',
    'Velvet',
    'Suits',
    'Dress Shirts',
    'Gowns / Dresses',
    'Uniforms',
    'Baby Clothes',
    'Delicates / Lingerie',
    'Athletic Wear',
  ];

  final List<String> beddingItems = [
    'Beddings',
    'Curtains',
    'Blanket',
    'Comforter',
    'Fleece',
    'Quilt',
  ];

  late final Map<String, bool> selectedRegularLaundryTypes;
  late final Map<String, bool> selectedBeddingItems;
  late final Map<String, int> beddingQuantities;

  bool othersSelected = false;
  String othersText = '';
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRegularLaundryTypes = {
      for (var type in regularLaundryTypes) type: false
    };
    selectedBeddingItems = {for (var item in beddingItems) item: false};
    beddingQuantities = {for (var item in beddingItems) item: 1};
  }

  double _getSelectedBeddingTotal(double unitPrice) {
    double total = 0;
    selectedBeddingItems.forEach((item, selected) {
      if (selected) {
        total += (beddingQuantities[item] ?? 0) * unitPrice;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04D26F),
        title: const Text(
          'Wash Cleaning',
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
            const Icon(Icons.local_laundry_service,
                size: 50, color: const Color(0xFF170CFE)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Wash Cleaning',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF170CFE)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Standard washing and drying service for everyday clothes. Free fold included.',
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
        final double washBase =
            double.tryParse(data['wash']?.toString() ?? '0') ?? 0;
        final double singleQueenUnit =
            double.tryParse(data['singleQueen']?.toString() ?? '0') ?? 0;
        final washNote = data['washNote']?.toString() ?? '';

        final double total =
            washBase + _getSelectedBeddingTotal(singleQueenUnit);
        final totalStr = total.toStringAsFixed(2);

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
                        color: Colors.black54),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(text: '₱ $totalStr'),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                washNote,
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
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Type Of Laundry (Regular Clothes)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: Scrollbar(
                child: ListView(
                  children: [
                    ...regularLaundryTypes.map((type) {
                      return _miniCheckboxTile(
                        label: type,
                        value: selectedRegularLaundryTypes[type],
                        onChanged: (val) => setState(() =>
                            selectedRegularLaundryTypes[type] = val ?? false),
                      );
                    }),
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
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF04D26F)),
                            ),
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
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('pricing_management')
              .doc('pricing')
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final singleQueen = data['singleQueen']?.toString() ?? '—';
            final double singleQueenUnit = double.tryParse(singleQueen) ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Single/Queen Size Bulky Items = ₱$singleQueen per-piece',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...beddingItems.map((item) {
                  return Column(
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
                  );
                }),
                const SizedBox(height: 4),
                Text(
                  'Selected bulky items total: ₱${_getSelectedBeddingTotal(singleQueenUnit).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                )
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
      child: TextField(
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
                backgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              label: const Text('Add to Cart',
                  style: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.black),
              label: const Text('Order Now',
                  style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    final selectedRegular = selectedRegularLaundryTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final selectedBedding = selectedBeddingItems.entries
        .where((e) => e.value)
        .map((e) => '${e.key} x${beddingQuantities[e.key]}')
        .toList();
    final allSelected = [
      ...selectedRegular,
      ...selectedBedding,
      if (othersSelected && othersText.trim().isNotEmpty) 'Others: $othersText',
      if (noteController.text.trim().isNotEmpty)
        'Note: ${noteController.text.trim()}'
    ];
    debugPrint('Selected laundry types: $allSelected');
  }

  Widget _miniCheckboxTile({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF04D26F),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}
