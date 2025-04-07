import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

@RoutePage()
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false; // Prevent multiple scans at once

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isProcessing) return; // Ignore if already processing

              final List<Barcode> barcodes = capture.barcodes;
              // final Uint8List? image = capture.image; // If you need the image

              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _isProcessing = true; // Mark as processing
                  });
                  print('QR Code Found: $code');
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          // Optional: Add a scanning overlay UI here
          Center(
              child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2))))
        ],
      ),
    );
  }
}
