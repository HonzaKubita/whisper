import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage()
class MyQRCodeScreen extends StatelessWidget {
  final String publicKey;

  const MyQRCodeScreen({super.key, required this.publicKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('My Public Key', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fit content vertically
            children: [
              // --- QR Code ---
              Container(
                color: Colors.white, // Ensure white background for QR
                child: QrImageView(
                  data: publicKey,
                  version: QrVersions.auto,
                  size: 250.0, // Adjust size as needed
                  gapless: false, // Recommended for better scanning
                  // errorCorrectionLevel: QrErrorCorrectLevel.H, // High correction
                ),
              ),
              const SizedBox(height: 30),

              // --- Public Key Text (Selectable) ---
              SelectableText(
                publicKey,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 15),

              // --- Copy Button ---
              TextButton.icon(
                icon: const Icon(Icons.copy_outlined,
                    size: 18, color: Colors.black),
                label: const Text('Copy Key',
                    style: TextStyle(color: Colors.black)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: publicKey));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Public key copied to clipboard'),
                      backgroundColor: Colors.black87,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
