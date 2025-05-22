import 'package:flutter/material.dart';
import '../Start,Signup,Login/2_welcome_page.dart'; // For logout redirect to HomeScreen
import '2_customer_washCleaningPage.dart';
import '3_customer_dryCleaningPage.dart';
import '4_customer_washDryPressPage.dart';
import '5_customer_ironingPage.dart';
import '6_customer_accessoryCleaningPage.dart';
import '7_customer_cartPage.dart';
import '8_customer_profilePage.dart';
// Note: All services should not have navigation bottom bar, users can use the appbar back button instead for cleaner UI.

class CustomerHomePage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const CustomerHomePage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  Future<bool> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD9D9D9),
        title: Row(
          children: [
            const Icon(Icons.error_outline,
                color: const Color(0xFFE57373), size: 28),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
          backgroundColor: const Color(0xFF04D26F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 2,
          onTap: (index) async {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => CartPage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero, // No transition animation
                    reverseTransitionDuration: Duration.zero,
                  ),
                );

                break;
              case 4:
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => CustomerProfilePage(
                      fullName: widget.fullName,
                      address: widget.address,
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
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Invoice'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), label: 'Schedules'),
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
                    color: const Color(0xFF04D26F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 30),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFF170CFE),
                            child: Icon(Icons.person,
                                color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "WELCOME!",
                            style: TextStyle(
                              color: const Color(0xFF170CFE),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(widget.fullName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20)),
                          Text("Five Stars Laundromat | CUSTOMER",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 18)),
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
                      _buildDashboardTile(
                          Icons.local_laundry_service, 'Wash Cleaning', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => washCleaningPage(
                                fullName: widget.fullName,
                                address: widget.address,
                                contact: widget.contact,
                                email: widget.email,
                              ),
                          ),
                        );
                      }),
                      _buildDashboardTile(Icons.dry_cleaning, 'Dry Cleaning', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => dryCleaningPage(
                                fullName: widget.fullName,
                                address: widget.address,
                                contact: widget.contact,
                                email: widget.email,
                              ),
                          ),
                        );
                      }),
                      _buildDashboardTile(
                          Icons.inventory, 'Wash, Dry & Press Service', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => washDryPressPage(
                                fullName: widget.fullName,
                                address: widget.address,
                                contact: widget.contact,
                                email: widget.email,
                              ),
                          ),
                        );
                      }),
                      _buildDashboardTile(Icons.iron, 'Ironing Service', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ironingPage(
                                fullName: widget.fullName,
                                address: widget.address,
                                contact: widget.contact,
                                email: widget.email,
                              ),
                          ),
                        );
                      }),
                      _buildDashboardTile(
                          Icons.cleaning_services, 'Accessory Cleaning', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const accessoryCleaningPage()),
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
                      'Transaction Logs:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildActivityLog(
                    "Log #1", "Waiting for your payment", "15:00"),
                _buildActivityLog("Log #2", "Rider is on the way", "14:30"),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDashboardTile(
      IconData icon, String label, VoidCallback onTap) {
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
            Icon(icon, size: 40, color: const Color(0xFF170CFE)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: const Color(0xFF170CFE),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActivityLog(String customer, String action, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF04D26F),
              radius: 20,
              child: Text(
                customer.split(' ').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text("$customer $action")),
            Text(time, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
