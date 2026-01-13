import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'manual_menu_screen.dart';

class SnapMenuScreen extends StatelessWidget {
  const SnapMenuScreen({super.key});

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (picked == null) return;

    // TEMP: later connect to MenuService.extractMenu()
    debugPrint("Captured image path: ${picked.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ─────────────────── APP BAR ───────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Snap Menu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────── BODY ───────────────────
      body: Column(
        children: [
          const Spacer(),

          // Camera Illustration
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFF3FF),
                ),
              ),
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F1FF),
                ),
              ),
              Image.asset(
                'assets/illustrations/menu_camera.png',
                height: 160,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.camera_alt_rounded,
                    size: 160,
                    color: Color(0xFF0C2D48),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Title
          const Text(
            'Digitize Your Menu',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C2D48),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Snap a photo to build your POS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),

      // ─────────────────── ACTION BUTTONS ───────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Capture Menu → CAMERA DIRECT
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Capture Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _openCamera(context),
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

              const SizedBox(height: 14),

              // Enter Menu Manually
              SizedBox(
                width: double.infinity,
                height: 52,
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
                    foregroundColor: const Color(0xFF6B4EFF),
                    side: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Enter Menu Manually',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
