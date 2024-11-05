import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScreen extends ConsumerStatefulWidget {
  const QrCodeScreen({super.key});

  @override
  ConsumerState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.start();
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            //scanWindow: Rect.fromLTWH(0, 0, 400, 400),
            controller: controller,
            onDetect: (data) {
              if (!isDetecting) {
                isDetecting = true;
                _handleQRCodeDetected(data.barcodes[0].rawValue);
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleQRCodeDetected(String? qrCode) {
    if (qrCode != null) {
      // Handle the scanned QR code
      print('Scanned QR Code: $qrCode');

      // Reset the detection flag after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        isDetecting = false;
        Navigator.pop(context, qrCode);
      });
    }
  }
}
