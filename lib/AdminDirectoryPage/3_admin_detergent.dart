import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDetergentPage extends StatefulWidget {
  final String employeeId;
  final String branch;

  const AdminDetergentPage({
    super.key,
    required this.employeeId,
    required this.branch,
  });

  @override
  State<AdminDetergentPage> createState() => _AdminDetergentPageState();
}

class _AdminDetergentPageState extends State<AdminDetergentPage> {
  /* ────────────────────────────  DETERGENT / PRICING FORM  ────────────────────────── */
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _pricingController = TextEditingController();
  String? _selectedAvailability;
  final List<String> _availabilityOptions = ['Yes', 'No'];

  /* ────────────────────────────  STYLES / COLORS  ───────────────────────── */
  final Color highlightColor = const Color(0xFF04D26F);

  /* ─────────────────────  DETERGENT FORM SUBMIT (unchanged)  ────────────── */
  Future<void> _submitForm() async {
    final String type = _typeController.text.trim();
    final String? availability = _selectedAvailability;
    final String pricingText = _pricingController.text.trim();

    if (type.isEmpty || availability == null || pricingText.isEmpty) {
      _showCustomSnackBar('Please fill all fields!', isError: true);
      return;
    }

    double? pricing = double.tryParse(pricingText);
    if (pricing == null || pricing < 0) {
      _showCustomSnackBar('Invalid pricing. Enter a positive number.', isError: true);
      return;
    }

    final existing = await FirebaseFirestore.instance
        .collection('detergent_management')
        .where('detergentSoftener', isEqualTo: type)
        .where('branch', isEqualTo: widget.branch)
        .get();

    if (existing.docs.isNotEmpty) {
      _showCustomSnackBar('Detergent/Softener already exists.', isError: true);
      return;
    }

    await FirebaseFirestore.instance.collection('detergent_management').add({
      'employeeId': widget.employeeId,
      'detergentSoftener': type,
      'availability': availability,
      'branch': widget.branch,
      'pricingPerLoad': pricing,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _showCustomSnackBar('Item added successfully!', isError: false);

    _typeController.clear();
    _pricingController.clear();
    setState(() => _selectedAvailability = null);
  }

  /* ─────────────  TOGGLE SERVICE (IRON / ACCESSORY) AVAILABILITY  ───────── */
  Future<void> _toggleServiceAvailability(
      String fieldKey, String currentValue) async {
    final newValue = (currentValue == 'Yes') ? 'No' : 'Yes';

    await FirebaseFirestore.instance
        .collection('detergent_management')
        .doc('${widget.branch}_service_availability')
        .set({
      fieldKey: newValue,
      'branch': widget.branch,
      'employeeId': widget.employeeId,
      'timestamp_${fieldKey}': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /* ────────────────  TOGGLE DETERGENT/SOFTENER AVAILABILITY  ────────────── */
  Future<void> _updateAvailability(String docId, dynamic currentValue) async {
    final newValue =
    (currentValue == true || currentValue == 'Yes') ? 'No' : 'Yes';
    await FirebaseFirestore.instance
        .collection('detergent_management')
        .doc(docId)
        .update({'availability': newValue});
  }

  /* ───────────────────────────  CARD BUILDER  ───────────────────────────── */
  Widget _buildServiceCard(
      String label, String fieldKey, String currentValue) {
    final availability = (currentValue == 'Yes') ? 'Yes' : 'No';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text('Branch: ${widget.branch}'),
        trailing: GestureDetector(
          onTap: () => _toggleServiceAvailability(fieldKey, availability),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: availability == 'Yes'
                  ? const Color(0xFF04D26F)
                  : const Color(0xFFE57373),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              availability,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ─────────────────────────────  SNACKBAR  ─────────────────────────────── */
  void _showCustomSnackBar(String message, {required bool isError}) {
    final snackBar = SnackBar(
      content: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: isError ? const Color(0xFFE57373) : highlightColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /* ─────────────────────────────  EDIT PRICE PER LOAD METHOD/FUNCTION  ─────────────────────────────── */
  void _showEditPriceDialog(BuildContext context, String docId, String currentPrice) {
    final TextEditingController priceController = TextEditingController(text: currentPrice);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pricing Per Load'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Enter new price'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text.trim());
              if (newPrice != null) {
                await FirebaseFirestore.instance
                    .collection('detergent_management')
                    .doc(docId)
                    .update({'pricingPerLoad': newPrice});
                Navigator.pop(context);
              } else {
                // Optionally show error
              }
            },
          ),
        ],
      ),
    );
  }

  /* ───────────────────────────────  BUILD  ──────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170CFE),
        title: const Text(
          'Detergent / Service Management',
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
          Theme.of(context).colorScheme.copyWith(primary: highlightColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* ──────────────────  ADD NEW DETERGENT/SOFTENER  ────────────────── */
                const Text(
                  'ADD ITEMS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF170CFE),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Laundry Detergent, Fabric Softener, Other Cleaning Agents',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText:
                    'Laundry Detergent/Fabric Softener/Cleaning Agents',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: highlightColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                TextField(
                  controller: _pricingController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Pricing Per Load (₱)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: highlightColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedAvailability,
                  items: _availabilityOptions
                      .map((status) =>
                      DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedAvailability = value),
                  decoration: InputDecoration(
                    labelText: 'Availability',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: highlightColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Add Detergent/Softener',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                /* ──────────────────────────  DIVIDER  ───────────────────────── */
                const SizedBox(height: 30),
                const Divider(thickness: 2),

                /* ─────────────  SERVICE AVAILABILITY (IRON & ACCESSORY)  ─────────── */
                const SizedBox(height: 10),
                const Text(
                  'SERVICE AVAILABILITY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF170CFE),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage service availability per-branch\n- Tap the badge to toggle Yes / No',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('detergent_management')
                      .doc('${widget.branch}_service_availability')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.data() as Map<String, dynamic>?;

                    final ironAvail =
                        data?['ironPressingAvailability'] ?? 'No';
                    final accessoryAvail =
                        data?['accessoryCleaningAvailability'] ?? 'No';

                    return Column(
                      children: [
                        _buildServiceCard('Iron Pressing',
                            'ironPressingAvailability', ironAvail),
                        _buildServiceCard('Accessory Cleaning',
                            'accessoryCleaningAvailability', accessoryAvail),
                      ],
                    );
                  },
                ),

                /* ──────────────────────────  DIVIDER  ───────────────────────── */
                const SizedBox(height: 30),
                const Divider(thickness: 2),
                const SizedBox(height: 10),

                /* ───────────────  EXISTING DETERGENT/SOFTENER CARDS  ────────────── */
                const Text(
                  'EXISTING ITEMS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF170CFE),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Detergents, Softeners, Other Cleaning Agents\n- Tap the badge to toggle Yes / No',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('detergent_management')
                      .where('branch', isEqualTo: widget.branch)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'No detergents/softeners found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data =
                        docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final detergentName = data['detergentSoftener'] ?? '';
                        final rawPricing = data['pricingPerLoad'];
                        final pricingPerLoad = (rawPricing is num)
                            ? (rawPricing % 1 == 0 ? rawPricing.toInt().toString() : rawPricing.toString())
                            : '';
                        final branchName = data['branch'] ?? '';
                        final addedBy      = data['employeeId'] ?? '';
                        final rawAvailability = data['availability'];
                        final availability = (rawAvailability == true ||
                            rawAvailability == 'Yes')
                            ? 'Yes'
                            : 'No';

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$detergentName - ₱$pricingPerLoad',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF170CFE),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showEditPriceDialog(context, docId, pricingPerLoad);
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // smaller font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Branch: $branchName'),
                                Text('Added by ID: $addedBy', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () => _updateAvailability(docId, availability),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: availability == 'Yes' ? const Color(0xFF04D26F) : const Color(0xFFE57373),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  availability,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
