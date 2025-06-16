import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '10_customer_schedulesPage.dart';

class OrderingPage extends StatefulWidget {
  /* ───────── USER INFO (always required) ───────── */
  final String fullName;
  final String address;
  final String email;
  final String contact;

  /* ───────── SINGLE-SERVICE FIELDS (optional) ───────── */
  final String? serviceType;
  final List<String>? typeOfLaundry;
  final Map<String, int>? bulkyItems;
  final double? washBase;
  final double? dryBase;
  final double? priceOfBulkyItems;
  final String? personalRequest;
  final String? delicatesWashMethod; // For hand wash/machine wash delicates

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
    /* single-service params */
    this.serviceType,
    this.typeOfLaundry,
    this.bulkyItems,
    this.washBase,
    this.dryBase,
    this.priceOfBulkyItems,
    this.personalRequest,
    this.delicatesWashMethod, // For hand wash/machine wash delicates
    /* multi-service params */
    this.selectedItems,
    /* mandatory grand total */
    required this.totalPrice,
  })  : assert(
  (selectedItems != null && selectedItems.isNotEmpty) ||
      (serviceType != null),
  'Either selectedItems or serviceType must be supplied',
  ),
        super(key: key);

  @override
  State<OrderingPage> createState() => _OrderingPageState();
}

class _OrderingPageState extends State<OrderingPage> {


  /* ───────── Laundry Branches ───────── */
  final List<String> _branches = [
    'Santa Fe (Blk 2 Lot 1, Brgy. Santa Fe, Dasmariñas, Cavite)',
    'Santa Cristina (Blk F15 Lot 9, Brgy. Santa Cristina, Dasmariñas, Cavite)',
    'Area C (Blk H16 Lot 6, Brgy. San Roque, Dasmariñas, Cavite)',
    'Area E (Blk K9 Lot 1, Brgy. San Antonio De Padua 2, Dasmariñas, Cavite)',
  ];
  String? _selectedBranch;

  /* ───────── Preferred Detergents ───────── */
  List<Map<String, dynamic>> _availableDetergents = [];
  List<String> _selectedDetergents = [];

  /* ───────── Service Availability ───────── */
  bool _ironPressingAvailable = false;
  bool _accessoryCleaningAvailable = false;

  /* ───────── Order Method & Payment ───────── */
  final List<String> _orderMethods = [
    'Home Pickup & Shop Delivery',
    'Self Drop-off & Shop Delivery',
    'Home Pickup & Self-Pickup',
  ];
  final Map<String, String> _orderMethodNotes = {
    'Home Pickup & Shop Delivery':
    'The laundry shop sends staff to collect clothes from the customer\'s doorstep and delivers the cleaned laundry back to the customer.',
    'Self Drop-off & Shop Delivery':
    'The customer drops off the laundry at the shop and the shop delivers it back once cleaned.',
    'Home Pickup & Self-Pickup':
    'The laundry shop picks up the clothes from the customer\'s home and the customer picks them up from the shop once cleaned.',
  };
  String? _selectedOrderMethod;
  static const String _modeOfPayment = 'Cash on Delivery / Cash on Self-Pickup';

  /* simple loading flag so user can’t double-tap */
  bool _saving = false;

  /* ───────── helpers for SINGLE service ───────── */
  double get _singleBase {
    if (widget.typeOfLaundry == null || widget.typeOfLaundry!.isEmpty) return 0;
    return widget.washBase ?? widget.dryBase ?? 0;
  }

  bool get _isMultiOrder =>
      widget.selectedItems != null && widget.selectedItems!.isNotEmpty;

/* ───────── ORDER-ID GENERATOR ───────── */
  String _generateOrderId() {
    final now = DateTime.now();
    final ts = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final suffix = now.microsecondsSinceEpoch.remainder(1000).toString().padLeft(3, '0');
    return 'ORD-$ts-$suffix';
  }

  /* ───────── SAVE ORDER TO FIRESTORE ───────── */
  Future<String> _saveOrder() async {
    final orderId = _generateOrderId();

    final List<Map<String, dynamic>> items = _isMultiOrder
        ? widget.selectedItems!
        .map((d) => Map<String, dynamic>.from(d.data() as Map))
        .toList()
        : [
      {
        'serviceType': widget.serviceType,
        'typeOfLaundry': widget.typeOfLaundry,
        'bulkyItems': widget.bulkyItems,
        'washBase': widget.washBase,
        'dryBase': widget.dryBase,
        'priceOfBulkyItems': widget.priceOfBulkyItems,
        'personalRequest': widget.personalRequest,
        'totalPrice': widget.totalPrice,
      }
    ];

    // Merge selected and custom detergents with prices for Single-Card
    final List<Map<String, dynamic>> allSelectedDetergents = [];

    for (var label in _selectedDetergents) {
      final matched = _availableDetergents.firstWhere(
            (d) => d['detergentSoftener'] == label,
        orElse: () => {},
      );
      final price = matched['pricingPerLoad'] ?? 0;
      allSelectedDetergents.add({
        'label': label,
        'price': price,
      });
    }
    // If "Own Detergent" is selected, add custom input
    if (othersDetergentSelected && customDetergentText.trim().isNotEmpty) {
      allSelectedDetergents.add({
        'label': customDetergentText.trim(),
        'price': 0,
      });
    }

    // Merge selected and custom detergents with prices for Multi-Card
    final List<Map<String, dynamic>> preferredDetergentsList = [];

    if (_isMultiOrder) {
      final int count = widget.selectedItems!
          .where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final svc = data['serviceType'];
        return svc == 'Wash Cleaning' || svc == 'Wash, Dry & Press';
      })
          .length;

      for (final label in _selectedDetergents) {
        final matched = _availableDetergents.firstWhere(
              (d) => d['detergentSoftener'] == label,
          orElse: () => {},
        );
        final basePrice = (matched['pricingPerLoad'] ?? 0).toDouble();

        preferredDetergentsList.add({
          'label': label,
          'pricingPerLoad': basePrice,
          'loadCount': count,
          'total': basePrice * count,
        });
      }

      if (othersDetergentSelected && customDetergentText.trim().isNotEmpty) {
        preferredDetergentsList.add({
          'label': 'Own Detergent',
          'pricingPerLoad': 0,
          'loadCount': 0,
          'total': 0,
        });
      }
    }

    final orderData = {
      'orderId': orderId,
      'fullName': widget.fullName,
      'address': widget.address,
      'email': widget.email,
      'contact': widget.contact,
      'branch': _selectedBranch,
      'orderMethod': _selectedOrderMethod,
      'rushOrder': _isRushOrder,
      'paymentMethod': _modeOfPayment,
      // Preferred Detergents
      'preferredDetergents': _isMultiOrder ? preferredDetergentsList : allSelectedDetergents,

      // Delivery Fee Info
      'deliveryFee': {
        'amount': _computedFee,
        'note': _deliveryFeeLabel,
      },

      // Costs
      'grandTotal': _isMultiOrder
          ? _grandTotalWithFee
          : widget.totalPrice + _computedFee + _totalDetergentCost,

      'detergentTotal': _isMultiOrder
          ? _adjustedDetergentCost
          : _totalDetergentCost,
      'items': items,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('customer_orders')
        .add(orderData);

    return orderId;
  }

/* ───────── DELIVERY FEE LOGIC ───────── */
  double? _deliveryPickupFee; // Fetched from Firestore
  double get _computedFee {
    if (_deliveryPickupFee == null || _selectedOrderMethod == null) return 0;
    if (_selectedOrderMethod == 'Home Pickup & Shop Delivery') {
      return _deliveryPickupFee!;
    } else {
      return _deliveryPickupFee! / 2;
    }
  }

  /* ───────── DYNAMIC DETERGENT COST ───────── */
  double get _adjustedDetergentCost {
    final count = widget.selectedItems!
        .where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final svc = data['serviceType'];
      return svc == 'Wash Cleaning' || svc == 'Wash, Dry & Press';
    })
        .length;

    double total = 0;
    for (var label in _selectedDetergents) {
      final matched = _availableDetergents.firstWhere(
            (d) => d['detergentSoftener'] == label,
        orElse: () => {},
      );
      final base = (matched['pricingPerLoad'] ?? 0).toDouble();
      total += base * count;
    }

    return total;
  }

  double get _grandTotalWithFee {
    return widget.totalPrice + _computedFee + _adjustedDetergentCost;
  }

  @override
  void initState() {
    super.initState();
    _fetchDeliveryFee();
  }

  Future<void> _fetchDeliveryFee() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pricing_management')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _deliveryPickupFee = (data['deliveryPickupFee'] ?? 0).toDouble();
      });
    }
  }

  String get _deliveryFeeLabel {
    if (_selectedOrderMethod == null || _computedFee == 0) {
      return '₱ 0.00';
    }

    final fee = _computedFee.toStringAsFixed(2);
    String explanation;
    switch (_selectedOrderMethod) {
      case 'Home Pickup & Shop Delivery':
        explanation = 'Delivery & Pickup';
        break;
      case 'Self Drop-off & Shop Delivery':
        explanation = 'Delivery Only';
        break;
      case 'Home Pickup & Self-Pickup':
        explanation = 'Pickup Only';
        break;
      default:
        explanation = '';
    }
    return '₱ $fee ($explanation)';
  }

  /* ─────────RUSH SERVICE LOGIC ───────── */
  bool _isRushOrder = false;

  /* ─────────PREFERRED DETERGENT LOGIC & PRICE SINGLE-CARD ───────── */
  bool _requiresDetergent() {
    // Single booking
    if (widget.selectedItems == null) {
      return widget.serviceType == 'Wash Cleaning' || widget.serviceType == 'Wash, Dry & Press';
    }

    // Cart booking: check if any selected service requires detergent
    final List<String> detergentServices = ['Wash Cleaning', 'Wash, Dry & Press'];
    return widget.selectedItems!.any((doc) =>
        detergentServices.contains(doc['serviceType']));
  }

  // PRICE LOGIC FOR SINGLE SERVICE ORDERS
  double get _totalDetergentCost {
    double total = 0;
    for (var label in _selectedDetergents) {
      final matched = _availableDetergents.firstWhere(
            (d) => d['detergentSoftener'] == label,
        orElse: () => {},
      );
      final price = matched['pricingPerLoad'] ?? 0;
      total += (price is num) ? price.toDouble() : 0;
    }

    if (othersDetergentSelected && customDetergentText.trim().isNotEmpty) {
      total += 0; // Custom detergent has no price
    }

    return total;
  }


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
            if (_isMultiOrder)
              _multiServiceCard()
            else
              _singleServiceCard(),
            const SizedBox(height: 20),
            _branchDropdown(),
            if (_selectedBranch != null) ...[
              const SizedBox(height: 20),
              _detergentSelection(),
              const SizedBox(height: 20),
              _serviceAvailabilitySection(),
              const SizedBox(height: 20),
              _orderMethodSection(),
              const SizedBox(height: 20),
              _modeOfPaymentSection(),
            ],
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
              Text(widget.fullName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('• ${widget.email}'),
              const SizedBox(height: 4),
              Text('• ${widget.contact}'),
              const SizedBox(height: 4),
              Text('• ${widget.address}',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const Icon(Icons.person, color: Colors.black54, size: 75),
      ],
    ),
  );

  /* ─────────  SINGLE-SERVICE CARD ───────── */
  Widget _singleServiceCard() => _sectionCard(
    title: 'Service Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Service', widget.serviceType ?? ''),
        if (widget.typeOfLaundry != null && widget.typeOfLaundry!.isNotEmpty)
          _infoRow(
            'Base Price',
            (widget.delicatesWashMethod == 'Hand-wash' &&
                widget.typeOfLaundry!.contains('Delicates'))
                ? '₱ ${(_singleBase * 2).toStringAsFixed(2)} (Delicates Hand-wash)'
                : '₱ ${_singleBase.toStringAsFixed(2)}',
          ),
        if (widget.priceOfBulkyItems != null && widget.priceOfBulkyItems! > 0)
          _infoRow('Bulky / Accessory Price',
              '₱ ${widget.priceOfBulkyItems!.toStringAsFixed(2)}'),
        const Divider(),
        _infoRow('Service Total', '₱ ${widget.totalPrice.toStringAsFixed(2)}'),
        if (_selectedOrderMethod != null)
          _infoRow('Delivery/Pickup Fee', _deliveryFeeLabel), // Delivery Fee Detail
        _infoRow('Detergent/Softener Cost', '₱ ${_totalDetergentCost.toStringAsFixed(2)}'), // Detergent Cost Detail
        const SizedBox(height: 8),
        if (_isRushOrder)
          _infoRow('Rush Order', 'Yes (Complete Today)', bold: true), // Rush Feature Detail
        _infoRow('Grand Total', '₱ ${(widget.totalPrice + _computedFee + _totalDetergentCost).toStringAsFixed(2)}', // Total + Delivery Fee + Detergent Price
            bold: true),
        const SizedBox(height: 12),
        if (widget.typeOfLaundry != null && widget.typeOfLaundry!.isNotEmpty)
          _infoRow('Items', widget.typeOfLaundry!.join(', ')),
        if (widget.bulkyItems != null && widget.bulkyItems!.isNotEmpty)
          _infoRow(
            'Bulky / Accessories',
            widget.bulkyItems!.entries
                .map((e) =>
            '${e.key} – ${e.value} pc${e.value > 1 ? 's' : ''}')
                .join(', '),
          ),
        const SizedBox(height: 12),
        _infoRow('Personalized Request',
            widget.personalRequest?.isNotEmpty == true
                ? widget.personalRequest!
                : '—'),
        if (_selectedDetergents.isNotEmpty || (othersDetergentSelected && customDetergentText.isNotEmpty))
          ...[
            const Divider(),
            const Text('Preferred Detergents / Softeners:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._selectedDetergents.map((label) {
              final matched = _availableDetergents.firstWhere(
                    (d) => d['detergentSoftener'] == label,
                orElse: () => {},
              );
              final price = matched['pricingPerLoad'] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: Text('- $label: ₱${(price % 1 == 0) ? price.toInt() : price.toStringAsFixed(2)} Per-Load'),
              );
            }).toList(),
            if (othersDetergentSelected && customDetergentText.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: const Text('- Own Detergent: ₱0 | No Fee'),
              ),
          ],
      ],
    ),
  );


  /* ─────────  MULTI-SERVICE CARD ───────── */
  Widget _multiServiceCard() => _sectionCard(
    title: 'Selected Services',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.selectedItems!.map(_buildServiceDetail).toList(),
        const Divider(height: 32),
        _infoRow('Service Total', '₱ ${widget.totalPrice.toStringAsFixed(2)}'),
        if (_selectedOrderMethod != null)
          _infoRow('Delivery/Pickup Fee', _deliveryFeeLabel),
        _infoRow('Detergent/Softener Cost', '₱ ${_adjustedDetergentCost.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        if (_isRushOrder)
          _infoRow('Rush Order', 'Yes (Complete Today)', bold: true),
        _infoRow('Grand Total', '₱ ${_grandTotalWithFee.toStringAsFixed(2)}', bold: true),

        // Only show preferred detergent section if any service needs it
        if (_requiresDetergent() &&
            (_selectedDetergents.isNotEmpty || (othersDetergentSelected && customDetergentText.isNotEmpty)))
          ...[
            const Divider(),
            const Text('Preferred Detergents / Softeners:',
                style: TextStyle(fontWeight: FontWeight.bold)),

            ..._selectedDetergents.map((label) {
              final matched = _availableDetergents.firstWhere(
                    (d) => d['detergentSoftener'] == label,
                orElse: () => {},
              );
              final basePrice = (matched['pricingPerLoad'] ?? 0).toDouble();

              // Count relevant services
              final int count = widget.selectedItems!
                  .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final svc = data['serviceType'];
                return svc == 'Wash Cleaning' || svc == 'Wash, Dry & Press';
              })
                  .length;

              final totalPrice = basePrice * count;

              return Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: Text(
                  '- $label: ₱${basePrice.toStringAsFixed(2)} per load × $count = ₱${totalPrice.toStringAsFixed(2)}',
                ),
              );
            }).toList(),

            if (othersDetergentSelected && customDetergentText.trim().isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 8.0, top: 2),
                child: Text('- Own Detergent: ₱0 | No Fee'),
              ),
          ],
      ],
    ),
  );


  /* Builds the full detail for *one* service */
  Widget _buildServiceDetail(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final svc = d['serviceType'] ?? 'Service';
    final regItems = (d['typeOfLaundry'] as List?)?.cast<String>() ?? [];
    final delicatesWashMethod = d['delicatesWashMethod'];
    final bulkyMap =
        (d['numberOfBulkyItems'] as Map?)?.cast<String, dynamic>() ?? {};
    final double base = regItems.isNotEmpty
        ? (d['washBase'] ?? d['dryBase'] ?? 0).toDouble()
        : 0.0;
    final bulkyPrice = (d['priceOfBulkyItems'] ?? 0).toDouble();
    final total = (d['totalPrice'] ?? 0).toDouble();
    final personal = (d['personalRequest'] ?? '').toString();

    String _fmtBulky(Map<String, dynamic> m) => m.isEmpty
        ? 'None'
        : m.entries
        .map((e) =>
    '${e.key} – ${e.value} pc${e.value > 1 ? "s" : ""}')
        .join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('• $svc',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              Text('₱ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          if (base > 0)
            _infoRow(
              'Base Price',
              (delicatesWashMethod == 'Hand-wash' && regItems.contains('Delicates'))
                  ? '₱ ${(base * 2).toStringAsFixed(2)} (Delicates Hand-wash)'
                  : '₱ ${base.toStringAsFixed(2)}',
            ),

          if (bulkyMap.isNotEmpty) // To hide if none
          _infoRow('Bulky / Accessory Price',
              '₱ ${bulkyPrice.toStringAsFixed(2)}'),
          if (regItems.isNotEmpty) // To hide if none
            _infoRow('Items', regItems.join(', ')),
          if (bulkyMap.isNotEmpty) // To hide if none
          _infoRow('Bulky / Accessories', _fmtBulky(bulkyMap)),
          _infoRow('Personalized Request',
              personal.isNotEmpty ? personal : '—'),
          const Divider(height: 24),
        ],
      ),
    );
  }

  /* ─────────  BRANCH DROPDOWN ───────── */
  Widget _branchDropdown() => _sectionCard(
    title: 'Select 5-Stars Laundry Branch',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Choose a laundry branch nearest to your home address.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedBranch,
            hint: const Text('Choose a branch'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey), // Normal border color
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF04D26F), width: 2), // Focused border color & thickness
              ),
            ),
            items: _branches
                .map((branch) => DropdownMenuItem(
              value: branch,
              child: Text(
                branch,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedBranch = value;
                _availableDetergents = [];
                _selectedDetergents = [];
                _ironPressingAvailable = false;
                _accessoryCleaningAvailable = false;
                _selectedOrderMethod = null;
              });
              if (value != null) _fetchAvailableDetergents(value);
            },
          ),
        ),
      ],
    ),
  );

  /* ─────────  DETECT & LIST Detergents + Service Availability ───────── */
  void _fetchAvailableDetergents(String branch) async {
    final branchName = branch.split(' (').first;

    final detSnap = await FirebaseFirestore.instance
        .collection('detergent_management')
        .where('branch', isEqualTo: branchName)
        .where('availability', isEqualTo: 'Yes')
        .get();

    final serviceDoc = await FirebaseFirestore.instance
        .collection('detergent_management')
        .doc('${branchName}_service_availability')
        .get();

    setState(() {
      _availableDetergents = detSnap.docs.map((doc) => doc.data()).toList();
      _ironPressingAvailable =
          (serviceDoc.data()?['ironPressingAvailability'] ?? 'No') == 'Yes';
      _accessoryCleaningAvailable =
          (serviceDoc.data()?['accessoryCleaningAvailability'] ?? 'No') ==
              'Yes';
    });
  }

  bool othersDetergentSelected = false;
  String customDetergentText = '';

  Widget _detergentSelection() {
    // Only show the section for these service types
    final bool showDetergents = _requiresDetergent();
    if (!showDetergents) return const SizedBox.shrink(); // Hide the section

    if (_availableDetergents.isEmpty) {
      return _sectionCard(
        title: 'Preferred Detergents / Softeners / Cleaning Agents',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No stock available for the selected branch. Please check for any announcement or contact 5-Stars Laundromat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE57373),
              ),
            ),
          ),
        ),
      );
    }

    return _sectionCard(
      title: 'Preferred Detergents / Softeners / Cleaning Agents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 135,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // "Own Detergent" at the top
                    CheckboxListTile(
                      value: othersDetergentSelected,
                      activeColor: const Color(0xFF04D26F),
                      title: const Text(
                        'Own Detergent / Softener',
                        style: TextStyle(fontSize: 14),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          othersDetergentSelected = val ?? false;
                          if (othersDetergentSelected) {
                            // Clear selected detergents when own detergent is checked
                            _selectedDetergents.clear();
                          } else {
                            customDetergentText = '';
                          }
                        });
                      },
                    ),

                    if (othersDetergentSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, top: 4, bottom: 8),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Please specify',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          onChanged: (val) {
                            setState(() => customDetergentText = val);
                          },
                        ),
                      ),

                    // Available detergent list
                    ..._availableDetergents.map((item) {
                      final label = item['detergentSoftener'] ?? 'Unnamed';
                      final price = item['pricingPerLoad'];
                      final formattedPrice = price != null
                          ? '₱${(price % 1 == 0) ? price.toInt() : price.toStringAsFixed(2)} | Per-Load'
                          : '₱0';
                      final isChecked = _selectedDetergents.contains(label);
                      final isDisabled = othersDetergentSelected;

                      return CheckboxListTile(
                        value: isChecked,
                        activeColor: const Color(0xFF04D26F),
                        title: Text(
                          '$label - $formattedPrice',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDisabled ? Colors.grey : Colors.black,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -4),
                        contentPadding: EdgeInsets.zero,
                        onChanged: isDisabled
                            ? null
                            : (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedDetergents.add(label);
                            } else {
                              _selectedDetergents.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ─────────  SERVICE AVAILABILITY SECTION  ───────── */
  Widget _availabilityRow(String label, bool available) => Row(
    children: [
      Icon(
        available ? Icons.check_circle : Icons.cancel,
        color:
        available ? const Color(0xFF04D26F) : const Color(0xFFE57373),
        size: 20,
      ),
      const SizedBox(width: 6),
      Text(
        '$label: ${available ? 'Available' : 'Not available'}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: available
              ? const Color(0xFF04D26F)
              : const Color(0xFFE57373),
        ),
      ),
    ],
  );

  Widget _serviceAvailabilitySection() {
    final nothingAvailable =
        !_ironPressingAvailable && !_accessoryCleaningAvailable;

    return _sectionCard(
      title: 'Service Availability',
      child: nothingAvailable
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'Service not available for the selected branch. Please check for any announcement or contact 5-Stars Laundromat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE57373),
            ),
          ),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _availabilityRow('Iron Pressing', _ironPressingAvailable),
          const SizedBox(height: 8),
          _availabilityRow(
              'Accessory Cleaning', _accessoryCleaningAvailable),
        ],
      ),
    );
  }

  /* ───────── ORDER METHOD SECTION (modified) ───────── */
  Widget _orderMethodSection() => _sectionCard(
    title: 'Order Method',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._orderMethods.map(
              (m) => RadioListTile<String>(
            value: m,
            groupValue: _selectedOrderMethod,
            dense: true,
            activeColor: const Color(0xFF04D26F),
            title: Text(m, style: const TextStyle(fontSize: 14)),
            onChanged: (val) => setState(() => _selectedOrderMethod = val),
          ),
        ),
        if (_selectedOrderMethod != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _orderMethodNotes[_selectedOrderMethod!]!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rush Order (Complete today)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _isRushOrder,
                activeColor: const Color(0xFF04D26F),
                onChanged: (val) => setState(() => _isRushOrder = val),
              ),
            ],
          ),
          if (_isRushOrder) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Rush orders ensure all laundry services are completed within the same day.',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    ),
  );

  /* ───────── MODE OF PAYMENT SECTION (unchanged) ───────── */
  Widget _modeOfPaymentSection() => _sectionCard(
    title: 'Mode of Payment',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.payment,
              color: const Color(0xFF04D26F),
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              _modeOfPayment,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF04D26F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(
              Icons.info_outline,
              color: Color(0xFFFFD700),
              size: 18,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Finalized pricing will be shown in your INVOICE after weighing at our shop. '
                    'Extra charges may apply for over-sized, delicate, or special-care items.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );


  /* ───────── SERVICE-AVAILABILITY HELPERS ───────── */
  bool _needsIron(String? service) =>
      service?.toLowerCase().contains('iron') ?? false;

  bool _needsAccessory(String? service) =>
      service?.toLowerCase().contains('accessory') ?? false;

  bool _allRequestedServicesAvailable() {
    if (!_isMultiOrder) {
      return (!_needsIron(widget.serviceType) || _ironPressingAvailable) &&
          (!_needsAccessory(widget.serviceType) || _accessoryCleaningAvailable);
    }

    for (final doc in widget.selectedItems!) {
      final svc = (doc.data() as Map<String, dynamic>)['serviceType'] ?? '';
      if (_needsIron(svc) && !_ironPressingAvailable) return false;
      if (_needsAccessory(svc) && !_accessoryCleaningAvailable) return false;
    }
    return true;
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
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  fontWeight: bold ? FontWeight.bold : FontWeight.w400)),
        ),
      ],
    ),
  );

  /* ─────────  PLACE ORDER BUTTON ───────── */
  Widget _placeOrderButton(BuildContext context) {
    final bool showDetergents = _requiresDetergent();
    final bool noDetergents =  showDetergents && _availableDetergents.isEmpty;

    final bool servicesUnavailable = !_allRequestedServicesAvailable();
    final bool methodNotChosen     = _selectedOrderMethod == null;

    final bool detergentsRequiredButNotSelected = showDetergents && _availableDetergents.isNotEmpty && _selectedDetergents.isEmpty && !othersDetergentSelected;
    final bool canPlace = !noDetergents &&
        !servicesUnavailable &&
        !methodNotChosen &&
        !detergentsRequiredButNotSelected &&
        !_saving;

    String _disabledMsg() {
      if (_selectedBranch == null)  return 'Please select a laundry branch.';
      if (methodNotChosen)          return 'Please select an order method.';
      if (detergentsRequiredButNotSelected) return 'Please select your preferred detergent/softener.';
      if (noDetergents)             return 'No detergents/softeners are in stock for this branch.';
      return 'Selected service(s) not available for this branch.';
    }

    /* delete every selected cart-document (if this order came from the cart) */
    Future<void> _deleteCartSelections() async {
      if (widget.selectedItems == null) return;                  // direct-booking, nothing to delete
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in widget.selectedItems!) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: canPlace ? const Color(0xFF04D26F) : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: _saving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.shopping_bag, color: Colors.white),
        label: Text(
          _saving ? 'Placing Order…' : 'Place Order',
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: canPlace
            ? () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFFD9D9D9),
              title: Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Color(0xFF04D26F), size: 28),
                  SizedBox(width: 10),
                  Text('Confirm Order', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: const Text(
                'Are you sure all the order details are correct?',
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF04D26F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, Place Order'),
                ),
              ],
            ),
          );
          if (confirm != true) return;
          setState(() => _saving = true);
          try {
            final orderId = await _saveOrder();
            await _deleteCartSelections();

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
                        'Order #$orderId placed successfully!',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => scheduledOrderPage(
                  fullName: widget.fullName,
                  address: widget.address,
                  contact: widget.contact,
                  email:   widget.email,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saving order: $e'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _saving = false);
          }
        }
            : () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_disabledMsg()),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      ),
    );
  }
}
