import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'manual_menu_screen.dart';
import 'menu_service.dart';

class MenuPromptScreen extends StatefulWidget {
  const MenuPromptScreen({super.key});

  @override
  State<MenuPromptScreen> createState() => _MenuPromptScreenState();
}

class _MenuPromptScreenState extends State<MenuPromptScreen> {
  final _picker = ImagePicker();
  final _menuService = MenuService();

  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final items = await _menuService.extractMenu(File(picked.path));

      if (!mounted) return;

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not detect any menu items. Try a clearer photo.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManualMenuScreen(initialItems: items),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu extraction failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showPickOptions() {
    if (_isProcessing) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Snap Menu",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: Column(
        children: [
          const Spacer(),

          // CAMERA ILLUSTRATION
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8EDFF),
                ),
              ),
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDDE3FF),
                ),
              ),
              Image.asset(
                'assets/illustrations/menu_camera.png',
                height: 160,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // TITLE
          const Text(
            "Digitize Your Menu",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C2D48),
            ),
          ),

          const SizedBox(height: 10),

          // SUBTITLE
          const Text(
            "Snap a photo to build your POS",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const Spacer(),

          // BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // CAPTURE MENU → OPENS CAMERA DIRECTLY
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _showPickOptions,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _isProcessing ? 'Processing…' : 'Capture Menu',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2A900),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                if (_isProcessing) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(minHeight: 4),
                ],

                const SizedBox(height: 16),

                // MANUAL ENTRY
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManualMenuScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Enter Menu Manually",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B4EFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
