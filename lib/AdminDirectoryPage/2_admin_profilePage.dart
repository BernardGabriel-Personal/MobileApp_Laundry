import 'package:flutter/material.dart';
import '../AdminDirectoryPage/1_admin_homepage.dart'; // Update this path if needed
import '../Start,Signup,Login/2_welcome_page.dart'; // For logout redirect to HomeScreen

class AdminProfilePage extends StatefulWidget {
  final String fullName;
  final String branch;
  final String employeeId;
  final String email;
  final String contact;

  const AdminProfilePage({
    Key? key,
    required this.fullName,
    required this.branch,
    required this.employeeId,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  Future<bool> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        title: Row(
          children: const [
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    return shouldLogout == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldLogout = await _confirmLogout(context);
          if (shouldLogout) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECF0F1),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF170CFE),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 4,
          onTap: (index) async {
            switch (index) {
              case 0:
                final shouldLogout = await _confirmLogout(context);
                if (shouldLogout) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminHomePage(
                      fullName: widget.fullName,
                      branch: widget.branch,
                      employeeId: widget.employeeId,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Basket'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF170CFE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF04D26F),
                        child: Icon(Icons.person, size: 45, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Text(
                        widget.employeeId,
                        style: const TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      Text(
                        "${widget.branch} Branch",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoTile("Contact Number", widget.contact),
                _buildInfoTile("Email Address", widget.email.isNotEmpty ? widget.email : "N/A"),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF04D26F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Handle password change action
                      },
                      child: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              "$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
