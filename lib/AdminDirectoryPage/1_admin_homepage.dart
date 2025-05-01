import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF170CFE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket), label: 'Basket'),
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
                  color: const Color(0xFF170CFE),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF04D26F),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "WELCOME!",
                          style: TextStyle(
                            color: Color(0xFF04D26F),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Five-Stars Laundry Employee",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dashboard Grid
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
                        Icons.local_laundry_service, 'Detergent'),
                    _buildDashboardTile(Icons.attach_money, 'Pricing'),
                    _buildDashboardTile(
                        Icons.shopping_cart, 'Order Management'),
                    _buildDashboardTile(Icons.library_books, 'Log Book'),
                    _buildDashboardTile(Icons.bar_chart, 'Analytics'),
                    _buildDashboardTile(Icons.verified_user, 'Accounts'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Activity Logs Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Activity Logs:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildActivityLog("Samle Admin #1",
                  "made changes in the detergent stock!", "15:00"),
              _buildActivityLog(
                  "Sample Admin #2", "Viewed the customers log.", "14:30"),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Dashboard Tile Builder
  static Widget _buildDashboardTile(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Color(0xFF04D26F)), // Increased icon size
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
    );
  }

  // Activity Log Entry Builder
  static Widget _buildActivityLog(String admin, String action, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF04D26F),
              radius: 20,
              child: Text(
                admin.split(' ').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text("$admin $action"),
            ),
            Text(
              time,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
