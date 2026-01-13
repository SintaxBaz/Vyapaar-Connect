import 'package:flutter/material.dart';

class PosGridScreen extends StatefulWidget {
  const PosGridScreen({super.key});

  @override
  State<PosGridScreen> createState() => _PosGridScreenState();
}

class _PosGridScreenState extends State<PosGridScreen> {
  // Dummy menu items
  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Chai', 'price': 10},
    {'name': 'Samosa', 'price': 10},
    {'name': 'Bun Maska', 'price': 15},
    {'name': 'Samosa', 'price': 15},
    {'name': 'Palpana', 'price': 15},
    {'name': 'Bun Maska', 'price': 15},
    {'name': 'Granoma', 'price': 10},
    {'name': 'Maran Dinatia', 'price': 10},
    {'name': 'Tuma Peppy', 'price': 10},
  ];
  
  // Track selected items and their quantities
  final Map<int, int> selectedItems = {};
  
  int get totalAmount {
    int total = 0;
    selectedItems.forEach((index, quantity) {
      total += (menuItems[index]['price'] as int) * quantity;
    });
    return total;
  }
  
  void addItem(int index) {
    setState(() {
      selectedItems[index] = (selectedItems[index] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Speed Dial POS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final quantity = selectedItems[index] ?? 0;
            
            return InkWell(
              onTap: () => addItem(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${item['price']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF2A900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (quantity > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C2D48),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0C2D48),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹$totalAmount',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: totalAmount > 0 ? () {
                    debugPrint('Checkout pressed. Total: ₹$totalAmount');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Checkout: ₹$totalAmount'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0C2D48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
