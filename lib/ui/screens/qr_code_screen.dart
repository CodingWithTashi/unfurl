import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScreen extends ConsumerStatefulWidget {
  const QrCodeScreen({super.key});

  @override
  ConsumerState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 200,
      height: 200,
    );
    controller.start();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            scanWindow: scanWindow,
            fit: BoxFit.contain,
            controller: controller,
            onDetect: (data) {
              if (!isDetecting) {
                isDetecting = true;
                _handleQRCodeDetected(data.barcodes[0].rawValue);
              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }

              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
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
      Future.delayed(const Duration(seconds: 1), () {
        isDetecting = false;
        // check mounted before popping the screen
        if (!mounted) return;
        Navigator.pop(context, qrCode);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
