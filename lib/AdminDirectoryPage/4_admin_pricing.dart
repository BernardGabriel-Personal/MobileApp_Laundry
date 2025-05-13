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
  };

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

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
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
                        _buildPriceField('Wash', _controllers['Wash']!),
                        _buildNote(
                            'Regular Clothes: Max 8 kg | Beddings, Curtains, Blankets: Max 6 kg'),
                        _buildPriceField('Dry', _controllers['Dry']!),
                        _buildNote(
                            'Regular Clothes: Max 8 kg | Beddings, Curtains, Blankets: Max 6 kg'),
                        _buildPriceField('Single/Queen Size (per piece)',
                            _controllers['Single/Queen Size (per piece)']!),
                        _buildNote('Comforters, Fleece Blanket, Quilt'),
                        _buildPriceField('Wash, Dry & Press (per kg)',
                            _controllers['Wash, Dry & Press (per kg)']!),
                        _buildPriceField('Press Only (per kg)',
                            _controllers['Press Only (per kg)']!),
                        _buildPriceField('Shoes/Bag/Helmet Cleaning',
                            _controllers['Shoes/Bag/Helmet Cleaning']!),
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
                        'Save Prices',
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
