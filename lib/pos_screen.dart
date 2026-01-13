import 'package:flutter/material.dart';
import 'menu_item.dart';


class POSScreen extends StatefulWidget {
  final List<MenuItem> menuItems;

  const POSScreen({super.key, required this.menuItems});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final Map<MenuItem, int> cart = {};
  int total = 0;

  void addItem(MenuItem item) {
    setState(() {
      cart[item] = (cart[item] ?? 0) + 1;
      total += item.price;
    });
  }

  void createPendingTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pending transaction created (mock)"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Dial POS"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // MAIN CONTENT
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.menuItems.isEmpty
            ? const Center(
                child: Text(
                  "No items found",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : GridView.builder(
                itemCount: widget.menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = widget.menuItems[index];
                  final qty = cart[item] ?? 0;

                  return GestureDetector(
                    onTap: () => addItem(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: qty > 0
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${item.price}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          if (qty > 0) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "x$qty",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),

      // BOTTOM TOTAL BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: ₹$total",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: total == 0 ? null : createPendingTransaction,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text("Create Bill"),
            ),
          ],
        ),
      ),
    );
  }
}
