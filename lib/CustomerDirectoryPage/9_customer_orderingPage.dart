import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /* ───────── helpers for SINGLE service ───────── */
  double get _singleBase {
    if (widget.typeOfLaundry == null || widget.typeOfLaundry!.isEmpty) return 0;
    return widget.washBase ?? widget.dryBase ?? 0;
  }

  bool get _isMultiOrder =>
      widget.selectedItems != null && widget.selectedItems!.isNotEmpty;

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
            _branchDropdown(), // ← branch selector
            if (_selectedBranch != null) ...[
              const SizedBox(height: 20),
              _detergentSelection(),
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
        _infoRow('Base Price', '₱ ${_singleBase.toStringAsFixed(2)}'),
        _infoRow('Bulky / Accessory Price',
            '₱ ${(widget.priceOfBulkyItems ?? 0).toStringAsFixed(2)}'),
        const Divider(),
        _infoRow('Total', '₱ ${widget.totalPrice.toStringAsFixed(2)}',
            bold: true),
        const SizedBox(height: 12),
        _infoRow(
            'Regular Laundry Items',
            (widget.typeOfLaundry != null &&
                widget.typeOfLaundry!.isNotEmpty)
                ? widget.typeOfLaundry!.join(', ')
                : 'None'),
        _infoRow(
            'Bulky / Accessories',
            (widget.bulkyItems != null && widget.bulkyItems!.isNotEmpty)
                ? widget.bulkyItems!.entries
                .map((e) =>
            '${e.key} – ${e.value} pc${e.value > 1 ? 's' : ''}')
                .join(', ')
                : 'None'),
        const SizedBox(height: 12),
        _infoRow('Personalized Request',
            widget.personalRequest?.isNotEmpty == true
                ? widget.personalRequest!
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
        ...widget.selectedItems!.map(_buildServiceDetail).toList(),
        const Divider(height: 32),
        _infoRow('Grand Total', '₱ ${widget.totalPrice.toStringAsFixed(2)}',
            bold: true),
      ],
    ),
  );

  /* Builds the full detail for *one* service */
  Widget _buildServiceDetail(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final svc = d['serviceType'] ?? 'Service';
    final regItems = (d['typeOfLaundry'] as List?)?.cast<String>() ?? [];
    final bulkyMap =
        (d['numberOfBulkyItems'] as Map?)?.cast<String, dynamic>() ?? {};
    final base = (d['washBase'] ?? d['dryBase'] ?? 0).toDouble();
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
          _infoRow('Base Price', '₱ ${base.toStringAsFixed(2)}'),
          _infoRow('Bulky / Accessory Price',
              '₱ ${bulkyPrice.toStringAsFixed(2)}'),
          _infoRow('Regular Laundry Items',
              regItems.isNotEmpty ? regItems.join(', ') : 'None'),
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
              });
              if (value != null) _fetchAvailableDetergents(value);
            },
          ),
        ),
      ],
    ),
  );

  /* ─────────  DETECT & LIST Detergents ───────── */
  void _fetchAvailableDetergents(String branch) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('detergent_management')
        .where('branch', isEqualTo: branch.split(' (').first) // branch name only
        .where('availability', isEqualTo: 'Yes')
        .get();

    setState(() {
      _availableDetergents = snapshot.docs
          .map((doc) => doc.data())
          .toList();
    });
  }

  Widget _detergentSelection() {
    if (_availableDetergents.isEmpty) {
      return _sectionCard(
        title: 'Preferred Detergents / Softeners / Cleaning Agents',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No stock available for the selected branch. Please check for any announcement or contact 5-Stars Laundromat.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE57373),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _sectionCard(
      title: 'Preferred Detergents / Softeners / Cleaning Agents',
      child: SizedBox(
        height: 135, // adjust height as needed
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _availableDetergents.map((item) {
                final label = item['detergentSoftener'] ?? 'Unnamed';
                final isChecked = _selectedDetergents.contains(label);
                return CheckboxListTile(
                  value: isChecked,
                  activeColor: const Color(0xFF04D26F),
                  title: Text(label, style: const TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (selected) {
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
            ),
          ),
        ),
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

  /* ─────────  PLACE ORDER (demo) ───────── */
  Widget _placeOrderButton(BuildContext context) {
    final bool isOutOfStock = _availableDetergents.isEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutOfStock
              ? Colors.grey // Grey background when disabled
              : const Color(0xFF04D26F),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: isOutOfStock
            ? null // disables the button when no stock
            : () {
          if (_selectedBranch == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a laundry branch.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF04D26F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Order placed at $_selectedBranch!\nPreferred: ${_selectedDetergents.join(', ')}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
