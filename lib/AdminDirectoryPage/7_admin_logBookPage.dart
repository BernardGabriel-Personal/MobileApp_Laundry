import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminLogBookPage extends StatefulWidget {
  final String fullName;
  final String branch;
  final String employeeId;
  final String email;
  final String contact;

  const AdminLogBookPage({
    Key? key,
    required this.fullName,
    required this.branch,
    required this.employeeId,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<AdminLogBookPage> createState() => _AdminLogBookPageState();
}

class _AdminLogBookPageState extends State<AdminLogBookPage> {
  /* ───────────────────────────  CONSTANTS & CONTROLLERS  ───────────────── */
  static const Color _highlightColor = Color(0xFF04D26F);
  static const Color _primaryColor   = Color(0xFF170CFE);
  static const Color _cardShadow     = Color(0x99000000);
  final TextEditingController _taskController = TextEditingController();

  /* ───────────────────────────────  HELPERS  ────────────────────────────── */
  String _formatTimestamp(Timestamp ts) =>
      DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate());

  Future<void> _addTask() async {
    final task = _taskController.text.trim();
    if (task.isEmpty) return;
    await FirebaseFirestore.instance.collection('admin_to_do_list').add({
      'employeeId': widget.employeeId,
      'task': task,
      'isDone': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _taskController.clear();
  }

  Future<void> _toggleTask(String docId, bool currentState) async {
    await FirebaseFirestore.instance
        .collection('admin_to_do_list')
        .doc(docId)
        .update({'isDone': !currentState});
  }

  Future<void> _deleteTask(String docId) async {
    await FirebaseFirestore.instance
        .collection('admin_to_do_list')
        .doc(docId)
        .delete();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  /* ───────────────────────────────  UI  ─────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    final double listHeight =
        MediaQuery.of(context).size.height * 0.35; // locked height sections

    return Scaffold(
      backgroundColor: const Color(0xFFECF0F3),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: const Text(
          'Log Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ───────────────────────  COMPLETED ORDERS  ────────────────────── */
            const Text(
              'COMPLETED ORDERS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            /* scroll-locked list */
            SizedBox(
              height: listHeight,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('customer_invoice')
                    .where('status', isEqualTo: 'completed')
                    .orderBy('invoiceTimestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No completed orders found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data()! as Map<String, dynamic>;

                      final String orderId   = data['orderId'] ?? '—';
                      final String cName     = data['fullName'] ?? 'N/A';
                      final String cBranch   = data['branch'] ?? 'N/A';
                      final String staffName = data['staffName'] ?? '—';
                      final double grandTotal =
                      (data['grandTotal'] ?? 0).toDouble();
                      final Timestamp ts =
                          data['invoiceTimestamp'] ?? Timestamp.now();

                      return Card(
                        color: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        shadowColor: _cardShadow,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            orderId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer: $cName'),
                              Text('Branch: $cBranch'),
                              Text('Handled by: $staffName'),
                              Text(_formatTimestamp(ts)),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _highlightColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _cardShadow,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '₱${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            /* ─────────────────────────────  TO-DO  ─────────────────────────── */
            const Text(
              'TO-DO LIST',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter new task',
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: _primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admin_to_do_list')
                  .where('employeeId', isEqualTo: widget.employeeId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'No tasks yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    final String docId = docs[index].id;
                    final String task  = data['task'] ?? '';
                    final bool isDone  = data['isDone'] ?? false;

                    return Card(
                      color: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shadowColor: _cardShadow,
                      child: ListTile(
                        leading: Checkbox(
                          value: isDone,
                          activeColor: _primaryColor,
                          onChanged: (_) => _toggleTask(docId, isDone),
                        ),
                        title: Text(
                          task,
                          style: TextStyle(
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: const Color(0xFFE57373)),
                          onPressed: () => _deleteTask(docId),
                        ),
                        onTap: () => _toggleTask(docId, isDone),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
