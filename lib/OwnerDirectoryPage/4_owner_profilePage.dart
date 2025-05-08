import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '1_owner_homepage.dart';
import '../Start,Signup,Login/2_welcome_page.dart';
// ignore_for_file: deprecated_member_use

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  _OwnerProfilePageState createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Map<String, int> branchEmployeeCounts = {};

  List<String> branches = [
    'Santa Cristina',
    'Santa Fe',
    'Area E',
    'Area C',
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeCounts();
    _fetchOwnerName();
  }

  Future<void> _fetchEmployeeCounts() async {
    final snapshot = await FirebaseFirestore.instance.collection('approved_admin').get();

    Map<String, int> counts = {};
    for (var branch in branches) {
      counts[branch] = snapshot.docs.where((doc) => doc['branch'] == branch).length;
    }

    setState(() {
      branchEmployeeCounts = counts;
    });
  }

  Future<void> _fetchOwnerName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('owner').doc('profile').get();
      if (doc.exists && doc.data()!.containsKey('fullName')) {
        _nameController.text = doc['fullName'];
      }
    } catch (e) {
      debugPrint('Error fetching owner name: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Full name cannot be empty')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('owner').doc('profile').set({
        'fullName': _nameController.text.trim(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    final shouldLogout = await _showLogoutConfirmation(context);
    return shouldLogout;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6E9D4),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Owner Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B5D74),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.save, color: const Color(0xFF04D26F)),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _saveProfile();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Branches',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: branches.map((branch) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(branch, style: const TextStyle(fontSize: 14)),
                          Text(
                            '${branchEmployeeCounts[branch] ?? 0} employees',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF170CFE),
            boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerHomePage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 30),
                onPressed: () {
                  // Already on profile page
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 30),
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6E9D4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE57373), size: 28),
            SizedBox(width: 10),
            Text('Are you leaving?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You can always log back in at any time.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFE57373),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    return false;
  }
}
