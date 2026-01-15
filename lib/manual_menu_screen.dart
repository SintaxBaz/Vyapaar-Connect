import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'menu_item.dart';
import 'pos_screen.dart';

class ManualMenuScreen extends StatefulWidget {
  final List<MenuItem>? initialItems;

  const ManualMenuScreen({super.key, this.initialItems});

  @override
  State<ManualMenuScreen> createState() => _ManualMenuScreenState();
}

class _ManualMenuScreenState extends State<ManualMenuScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  final List<MenuItem> items = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialItems;
    if (initial != null && initial.isNotEmpty) {
      items.addAll(initial);
    } else {
      _loadItems(); // Load from storage if no initial items
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsData = items.map((item) {
      return {
        'name': item.name,
        'price': item.price,
      };
    }).toList();
    await prefs.setString('menu_items', jsonEncode(itemsData));
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('menu_items');

    if (itemsJson != null) {
      try {
        final List<dynamic> itemsData = jsonDecode(itemsJson);
        setState(() {
          items.clear();
          for (var item in itemsData) {
            items.add(
              MenuItem(
                name: item['name'],
                price: item['price'],
              ),
            );
          }
        });
      } catch (e) {
        print('Error loading items: $e');
      }
    }
  }

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
    _saveItems(); // Save after adding
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveItems(); // Save after removing
  }

  void editItem(int index) {
    final item = items[index];
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Item name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: "Price (₹)"),
              keyboardType: TextInputType.number,
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
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  items[index] = MenuItem(
                    name: nameCtrl.text,
                    price: int.parse(priceCtrl.text),
                  );
                });
                _saveItems(); // Save after editing
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
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
                itemBuilder: (_, i) => Dismissible(
                  key: ValueKey('${items[i].name}-${items[i].price}-$i'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => removeItem(i),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(items[i].name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${items[i].price}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editItem(i),
                          ),
                        ],
                      ),
                    ),
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
