import 'package:flutter/material.dart';
import 'menu_item.dart';

// 👇 NEW IMPORTS
import 'screens/qr_screen.dart';
import 'services/bill_service.dart';

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

  void removeItem(MenuItem item) {
    setState(() {
      if (cart[item]! > 1) {
        cart[item] = cart[item]! - 1;
        total -= item.price;
      } else {
        total -= item.price * cart[item]!;
        cart.remove(item);
      }
    });
  }

  void deleteItem(MenuItem item) {
    setState(() {
      total -= item.price * (cart[item] ?? 0);
      cart.remove(item);
    });
  }

  void editQuantity(MenuItem item, int newQty) {
    setState(() {
      if (newQty <= 0) {
        deleteItem(item);
      } else {
        int difference = newQty - (cart[item] ?? 0);
        total += item.price * difference;
        cart[item] = newQty;
      }
    });
  }

  void _showEditDialog(BuildContext context, MenuItem item, int currentQty) {
    int newQty = currentQty;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Edit ${item.name}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Quantity: $newQty"),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        if (newQty > 1) {
                          setDialogState(() => newQty--);
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        newQty.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        setDialogState(() => newQty++);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  editQuantity(item, newQty);
                  Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
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

      // ================= MAIN GRID =================
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Edit button
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(context, item, qty);
                                  },
                                ),
                                // Quantity badge
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
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () => deleteItem(item),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),

      // ================= BOTTOM BAR =================
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
              onPressed: total == 0
                  ? null
                  : () async {
                      // Convert cart to backend-friendly data
                      final items = cart.entries.map((e) {
                        return {
                          "name": e.key.name,
                          "price": e.key.price,
                          "qty": e.value,
                        };
                      }).toList();

                      // Call backend (mocked)
                      final qrUrl = await BillService.createBill(
                        items: items,
                        total: total.toDouble(),
                      );

                      // Open QR screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrScreen(qrData: qrUrl),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
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
