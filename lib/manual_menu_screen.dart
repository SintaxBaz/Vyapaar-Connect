import 'package:flutter/material.dart';
import 'menu_item.dart';
import 'pos_screen.dart';

class ManualMenuScreen extends StatefulWidget {
  const ManualMenuScreen({super.key});

  @override
  State<ManualMenuScreen> createState() => _ManualMenuScreenState();
}

class _ManualMenuScreenState extends State<ManualMenuScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  final List<MenuItem> items = [];

  void addItem() {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

    setState(() {
      items.add(
        MenuItem(
          name: nameCtrl.text,
          price: int.parse(priceCtrl.text),
        ),
      );
      nameCtrl.clear();
      priceCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Menu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Item name",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(
                      labelText: "₹",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addItem,
                child: const Text("Add Item"),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    title: Text(items[i].name),
                    trailing: Text("₹${items[i].price}"),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => POSScreen(menuItems: items),
                          ),
                        );
                      },
                child: const Text(
                  "Continue to POS",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
