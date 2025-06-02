import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../AdminDirectoryPage/2_admin_profilePage.dart'; // Redirect to Profile page
import '../Start,Signup,Login/2_welcome_page.dart';      // For logout redirect to HomeScreen
import '../AdminDirectoryPage/3_admin_detergent.dart';   // Detergent Feature
import '../AdminDirectoryPage/4_admin_pricing.dart';     // Pricing Feature
import '../AdminDirectoryPage/7_admin_logBookPage.dart'; // LogBook Page
import '../AdminDirectoryPage/8_admin_announcementPage.dart'; // Announcement Page
import '../AdminDirectoryPage/5_admin_orderManagement.dart';  // Order Management Feature
import '6_admin_basketPage.dart';

// Note: All services should not have navigation bottom bar, users can use the appbar back button instead for cleaner UI.

class AdminHomePage extends StatefulWidget {
  final String fullName;
  final String branch;
  final String employeeId;
  final String email;
  final String contact;

  const AdminHomePage({
    Key? key,
    required this.fullName,
    required this.branch,
    required this.employeeId,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Future<bool> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE57373), size: 28),
            const SizedBox(width: 10),
            const Text('Are you leaving?', style: TextStyle(fontSize: 18)),
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
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        backgroundColor: const Color(0xFFECF0F3),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF170CFE),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 2,
          onTap: (index) async {
            switch (index) {
              case 0:
                final shouldLogout = await _confirmLogout(context);
                if (shouldLogout) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
                break;
              case 1:
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AdminBasketPage(
                      fullName: widget.fullName,
                      branch: widget.branch,
                      employeeId: widget.employeeId,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AdminProfilePage(
                      fullName: widget.fullName,
                      branch: widget.branch,
                      employeeId: widget.employeeId,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Basket'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Container(
                    color: const Color(0xFF170CFE),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF04D26F),
                            child: Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "WELCOME!",
                            style: TextStyle(
                              color: Color(0xFF04D26F),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(widget.fullName, style: const TextStyle(color: Colors.white, fontSize: 20)),
                          Text("${widget.branch} Branch | EMPLOYEE", style: const TextStyle(color: Colors.white70, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildDashboardTile(Icons.local_laundry_service, 'Detergent / Service Management', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminDetergentPage(
                            employeeId: widget.employeeId,
                            branch: widget.branch,
                          )),
                        );
                      }),
                      _buildDashboardTile(Icons.attach_money, 'Pricing Management', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminPricingPage(
                            employeeId: widget.employeeId,
                          )),
                        );
                      }),
                      _buildDashboardTile(Icons.shopping_cart, 'Order Management',() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  AdminOrderManagementPage(
                            employeeId: widget.employeeId,
                            fullName: widget.fullName,
                            branch: widget.branch,
                            contact: widget.contact,
                          )),
                        );
                      }),
                      _buildDashboardTile(Icons.library_books, 'Log Book', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  AdminLogBookPage(
                            employeeId: widget.employeeId,
                            fullName: widget.fullName,
                            branch: widget.branch,
                            contact: widget.contact,
                            email: widget.email,
                          )),
                        );
                      }),
                      _buildDashboardTile(Icons.announcement, 'Announcements', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  AdminAnnouncementPage(
                            employeeId: widget.employeeId,
                            fullName: widget.fullName,
                            branch: widget.branch,
                          )),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Announcements:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250, // fixed box height; only this section scrolls
                  child: _buildAnnouncementsStream(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ───────────────────────────────  UI HELPERS  ────────────────────────── */

  static Widget _buildDashboardTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF04D26F)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF04D26F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              'No announcements yet.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data()! as Map<String, dynamic>;

            final String fullName = data['fullName'] ?? 'Unknown';
            final String firstName = fullName.split(' ').first;
            final String announcer = 'Staff: $firstName';
            final String branch      = data['branch'] ?? 'N/A';
            final String message     = data['announcement'] ?? '';
            final Timestamp ts       = data['timestamp'] ?? Timestamp.now();
            final String timeString  = DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate());

            return _buildAnnouncementItem(announcer, branch, message, timeString);
          },
        );
      },
    );
  }

  static Widget _buildAnnouncementItem(String admin, String branch, String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF04D26F),
              radius: 20,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$admin ($branch)", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(message),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
