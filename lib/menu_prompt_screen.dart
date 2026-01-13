import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'manual_menu_screen.dart';

class MenuPromptScreen extends StatelessWidget {
  const MenuPromptScreen({super.key});

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (picked == null) return;

    // TEMP: Later you will send this to MenuService.extractMenu()
    debugPrint("Image captured: ${picked.path}");
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
                    onPressed: () => _openCamera(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      "Capture Menu",
                      style: TextStyle(
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
