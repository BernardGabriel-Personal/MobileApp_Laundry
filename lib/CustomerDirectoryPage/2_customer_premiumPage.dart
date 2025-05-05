import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class PremiumCarePage extends StatefulWidget {
  const PremiumCarePage({super.key});

  @override
  State<PremiumCarePage> createState() => _PremiumCarePageState();
}

class _PremiumCarePageState extends State<PremiumCarePage> {
  int _selectedIndex = 2; // Default to 'Home'
  String selectedOption = 'Delivery'; // To track Delivery vs Pick-up selection

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 1:
        Navigator.pushNamed(context, '/invoice');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/customer-home');
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Stain Removal'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Premium Care Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.emoji_events, size: 50, color: Colors.blue),
                    SizedBox(width: 16),
                    Text(
                      'Premium Care',
                      style: TextStyle(fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Price Info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '60 per 1kg',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                10))),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Minimum of 4kg',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                10))),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dropdowns
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: 'Cotton', child: Text('Cotton')),
                      DropdownMenuItem(value: 'Silk', child: Text('Silk')),
                    ],
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      hintText: 'Select type of Cloth',
                      filled: true,
                      fillColor: Colors.grey,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: 'Tide', child: Text('Tide')),
                      DropdownMenuItem(value: 'Downy', child: Text('Downy')),
                    ],
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      hintText: 'Select type of Detergent/Fabric',
                      filled: true,
                      fillColor: Colors.grey,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery & Pick-up Toggle Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedOption = 'Delivery';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedOption == 'Delivery' ? Colors
                            .green : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.delivery_dining,
                          color: selectedOption == 'Delivery'
                              ? Colors.white
                              : Colors.black),
                      label: Text(
                        'Delivery',
                        style: TextStyle(color: selectedOption == 'Delivery'
                            ? Colors.white
                            : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedOption = 'Pick-up';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedOption == 'Pick-up' ? Colors
                            .green : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.local_laundry_service,
                          color: selectedOption == 'Pick-up'
                              ? Colors.white
                              : Colors.black),
                      label: Text(
                        'Pick-up',
                        style: TextStyle(color: selectedOption == 'Pick-up'
                            ? Colors.white
                            : Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add to Cart & Order Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(
                          Icons.shopping_cart, color: Colors.black),
                      label: const Text(
                          'Add to Cart', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.black),
                      label: const Text(
                          'Order Now', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Invoice'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
