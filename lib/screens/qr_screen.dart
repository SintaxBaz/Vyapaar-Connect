import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  final String qrData;

  const QrScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan to Get Rewards"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              size: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Customer scans this QR to sign into Google Wallet",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
