import 'package:flutter/material.dart';
import '2_customer_premiumPage.dart';
import '3_customer_stainRemovalPage.dart';
import '4_customer_rushServicePage.dart';
import '5_customer_dryCleaningPage.dart';
import '6_customer_washAndFoldPage.dart';
import '7_customer_ironingPage.dart';

class CustomerHomePage extends StatefulWidget {
  final String fullName;
  const CustomerHomePage({super.key, required this.fullName});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 2;

  late String fullName;

  @override
  void initState() {
    super.initState();
    fullName = widget.fullName;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent re-navigation to same tab

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/Cart');
        break;
      case 1:
        Navigator.pushNamed(context, '/invoice');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/schedules');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'WELCOME!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Services Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PremiumCarePage()),
                        );
                      },
                      child: _buildServiceTile(Icons.verified, 'Premium Care'),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StainRemovalPage()),
                        );
                      },
                      child:
                      _buildServiceTile(Icons.checklist, 'Stain Removal'),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RushServicePage()),
                        );
                      },
                      child:
                      _buildServiceTile(Icons.speed, 'Rush Service'), // Fixed label
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DryCleaningPage()),
                        );
                      },
                      child: _buildServiceTile(
                          Icons.local_laundry_service, 'Dry Cleaning'),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WashAndFoldPage()),
                        );
                      },
                      child: _buildServiceTile(Icons.local_laundry_service_outlined, 'Wash & Fold'),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const IroningPage()),
                        );
                      },
                      child: _buildServiceTile(Icons.iron, 'Ironing Service'),
                    ),
                  ],
                ),
              ),

              // Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transactions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionTile(
                      icon: Icons.notifications_active,
                      text: 'Delivered Successfully!\nWaiting for your payment',
                      time: '15:00',
                    ),
                    const SizedBox(height: 10),
                    _buildTransactionTile(
                      icon: Icons.local_shipping,
                      text: 'The rider is on its way\nfor delivery',
                      time: '14:30',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Extra space for bottom nav
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoice'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildServiceTile(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, size: 40, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTransactionTile(
      {required IconData icon, required String text, required String time}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          Text(time, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
