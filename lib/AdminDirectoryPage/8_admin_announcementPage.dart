import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnnouncementPage extends StatefulWidget {
  final String fullName;
  final String branch;
  final String employeeId;

  const AdminAnnouncementPage({
    Key? key,
    required this.fullName,
    required this.branch,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  /* ─────────────────────────────  CONSTANTS  ───────────────────────────── */
  static const Color _primaryColor = Color(0xFF170CFE);
  static const Color _highlightColor = Color(0xFF04D26F);
  static const Color _cardShadow = Color(0x99000000);

  /* ──────────────────────────  OPTIONS & STATE  ────────────────────────── */
  final List<Map<String, String>> _options = [
    {
      'key': 'No water supply',
      'label': 'No water supply (Water service interruption)',
    },
    {
      'key': 'No electricity',
      'label': 'No electricity (Power outage)',
    },
  ];

  final Map<String, bool> _selected = {
    'No water supply': false,
    'No electricity': false,
  };

  final TextEditingController _customAnnouncementController =
  TextEditingController();

  /* ───────────────────────────────  HELPERS  ───────────────────────────── */
  Future<void> _submit() async {
    final chosen = _selected.entries.where((e) => e.value).map((e) => e.key);
    final customText = _customAnnouncementController.text.trim();

    if (chosen.isEmpty && customText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter at least one announcement.'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
      return;
    }

    // Save selected checkbox announcements
    for (final ann in chosen) {
      await FirebaseFirestore.instance.collection('announcements').add({
        'announcement': ann,
        'branch': widget.branch,
        'employeeId': widget.employeeId,
        'fullName': widget.fullName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Save custom message if available
    if (customText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('announcements').add({
        'announcement': customText,
        'branch': widget.branch,
        'employeeId': widget.employeeId,
        'fullName': widget.fullName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Clear selections and show confirmation
    setState(() {
      for (final key in _selected.keys) _selected[key] = false;
      _customAnnouncementController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _highlightColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 8),
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Announcement Saved!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ───────────────────────────────  BUILD  ─────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: const Text(
          'Announcement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ────────────────  CHECKBOX OPTIONS  ──────────────── */
            Card(
              color: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: _cardShadow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _options.map((opt) {
                    final key = opt['key']!;
                    return CheckboxListTile(
                      title: Text(opt['label']!),
                      activeColor: _primaryColor,
                      value: _selected[key],
                      onChanged: (val) =>
                          setState(() => _selected[key] = val ?? false),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /* ──────────────  CUSTOM TEXT FIELD  ─────────────── */
            Card(
              color: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: _cardShadow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _customAnnouncementController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Custom Announcement',
                    hintText: 'Type your message here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /* ────────────────  SUBMIT BUTTON  ──────────────── */
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Save Announcement',
                  style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _highlightColor,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
