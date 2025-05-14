import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPricingPage extends StatefulWidget {
  final String employeeId;

  const AdminPricingPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<AdminPricingPage> createState() => _AdminPricingPageState();
}

class _AdminPricingPageState extends State<AdminPricingPage> {
  final Color primaryColor = const Color(0xFF170CFE);
  final Color successColor = const Color(0xFF04D26F);

  final Map<String, TextEditingController> _controllers = {
    'Wash': TextEditingController(),
    'Dry': TextEditingController(),
    'Single/Queen Size (per piece)': TextEditingController(),
    'Wash, Dry & Press (per kg)': TextEditingController(),
    'Press Only (per kg)': TextEditingController(),
    'Shoes/Bag/Helmet Cleaning': TextEditingController(),
    'Delivery/Pickup Fee': TextEditingController(),
  };

  final TextEditingController _noteWashController = TextEditingController();
  final TextEditingController _noteDryController = TextEditingController();
  final TextEditingController _noteSingleController = TextEditingController();

  final String _documentId = "pricing";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingPricing();
  }

  Future<void> _loadExistingPricing() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('pricing_management')
          .doc(_documentId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _controllers['Wash']!.text = (data['wash'] ?? '').toString();
        _controllers['Dry']!.text = (data['dry'] ?? '').toString();
        _controllers['Single/Queen Size (per piece)']!.text =
            (data['singleQueen'] ?? '').toString();
        _controllers['Wash, Dry & Press (per kg)']!.text =
            (data['washDryPress'] ?? '').toString();
        _controllers['Press Only (per kg)']!.text =
            (data['pressOnly'] ?? '').toString();
        _controllers['Shoes/Bag/Helmet Cleaning']!.text =
            (data['shoesBagHelmet'] ?? '').toString();
        _controllers['Delivery/Pickup Fee']!.text =
            (data['deliveryPickupFee'] ?? '').toString();

        _noteWashController.text = data['washNote'] ?? '';
        _noteDryController.text = data['dryNote'] ?? '';
        _noteSingleController.text = data['noteSingle'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading pricing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndSavePricing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: successColor),
              const SizedBox(width: 8),
              Text(
                'Confirm Save',
                style: TextStyle(
                  color: successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
              'Are you sure you want to update the pricing? This will affect future transactions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
              ),
              child: const Text(
                'Yes, Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _savePricing();
    }
  }

  Future<void> _savePricing() async {
    final pricingData = {
      'wash': int.tryParse(_controllers['Wash']!.text.trim()) ?? 0,
      'dry': int.tryParse(_controllers['Dry']!.text.trim()) ?? 0,
      'singleQueen': int.tryParse(
              _controllers['Single/Queen Size (per piece)']!.text.trim()) ??
          0,
      'washDryPress': int.tryParse(
              _controllers['Wash, Dry & Press (per kg)']!.text.trim()) ??
          0,
      'pressOnly':
          int.tryParse(_controllers['Press Only (per kg)']!.text.trim()) ?? 0,
      'shoesBagHelmet': int.tryParse(
              _controllers['Shoes/Bag/Helmet Cleaning']!.text.trim()) ??
          0,
      'deliveryPickupFee':
          int.tryParse(_controllers['Delivery/Pickup Fee']!.text.trim()) ?? 0,
      'washNote': _noteWashController.text.trim(),
      'dryNote': _noteDryController.text.trim(),
      'noteSingle': _noteSingleController.text.trim(),
      'employeeId': widget.employeeId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('pricing_management')
          .doc(_documentId)
          .set(pricingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Prices saved successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save prices: $e'),
          backgroundColor: const Color(0xFFE57373),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          label: Text(
            '$label (₱)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: successColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteEditor(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: 2,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        decoration: InputDecoration(
          labelText: 'Note',
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _noteWashController.dispose();
    _noteDryController.dispose();
    _noteSingleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Pricing Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSectionTitle('Wash'),
                        _buildPriceField('Wash', _controllers['Wash']!),
                        _buildNoteEditor(_noteWashController),
                        _buildSectionTitle('Dry'),
                        _buildPriceField('Dry', _controllers['Dry']!),
                        _buildNoteEditor(_noteDryController),
                        _buildSectionTitle('Single/Queen Size (per piece)'),
                        _buildPriceField('Single/Queen Size (per piece)',
                            _controllers['Single/Queen Size (per piece)']!),
                        _buildNoteEditor(_noteSingleController),
                        _buildSectionTitle('Wash, Dry & Press (per kg)'),
                        _buildPriceField('Wash, Dry & Press (per kg)',
                            _controllers['Wash, Dry & Press (per kg)']!),
                        _buildSectionTitle('Press Only (per kg)'),
                        _buildPriceField('Press Only (per kg)',
                            _controllers['Press Only (per kg)']!),
                        _buildSectionTitle('Shoes/Bag/Helmet Cleaning'),
                        _buildPriceField('Shoes/Bag/Helmet Cleaning',
                            _controllers['Shoes/Bag/Helmet Cleaning']!),
                        _buildSectionTitle('Delivery / Pickup Fee'),
                        _buildPriceField('Delivery/Pickup Fee',
                            _controllers['Delivery/Pickup Fee']!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmAndSavePricing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Notes & Prices',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
