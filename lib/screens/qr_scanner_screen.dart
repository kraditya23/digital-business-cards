import 'package:card_app/utilities/firestore_paths.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  final void Function(String uid, String username) onScanned;
  const QrScannerScreen({super.key, required this.onScanned});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _dialogShown = false;
  bool _isLoading = false;
  bool _scanHandled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String? extractUsername(String code) {
    try {
      final uri = Uri.parse(code);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _handleDetection(String code) async {
    if (_scanHandled) return;
    final username = extractUsername(code);
    if (username != null && username.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final doc = await FirestorePaths.usernameMapping(username).get();
        if (doc.exists && doc.data()?['uid'] != null) {
          final uid = doc.data()!['uid'] as String;
          _scanHandled = true;
          Navigator.pop(context);
          widget.onScanned(uid, username);
          return;
        }
      } catch (_) {
        // continue to show error dialog
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    // Invalid QR or username not found; show dialog once
    if (_dialogShown) return;
    setState(() => _dialogShown = true);
    controller.stop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Scan Failed'),
        content: const Text('This QR code does not point to a valid Connecta profile.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _dialogShown = false);
              controller.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner UI
          Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                onDetect: (BarcodeCapture capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final raw = barcodes.first.rawValue;
                    if (raw != null) {
                      _handleDetection(raw);
                    }
                  }
                },
              ),

              const _ScannerOverlay(
                holeWidthFraction: 0.75, // 75% of screen width
                overlayColor: Color(0x88000000),
                cornerColor: Colors.blue,
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: _FlashlightButton(controller: controller),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

/// =============================
/// SCANNER OVERLAY (CustomPainter)
/// =============================

class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color cornerColor;
  final double holeWidthFraction;

  ScannerOverlayPainter({
    required this.overlayColor,
    required this.cornerColor,
    required this.holeWidthFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Compute the central “hole” rectangle (centered, square):
    final double holeWidth = size.width * holeWidthFraction;
    final double holeHeight = holeWidth; // keep it square
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect holeRect = Rect.fromCenter(
      center: center,
      width: holeWidth,
      height: holeHeight,
    );

    // 2) Begin a new layer so we can clear out the hole:
    Rect fullScreenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(fullScreenRect, Paint());

    // 3) Draw the full-screen semi-opaque overlay on this layer:
    final Paint overlayPaint = Paint()..color = overlayColor;
    canvas.drawRect(fullScreenRect, overlayPaint);

    // 4) “Punch out” the hole in the center (BlendMode.clear) on the same layer:
    final Paint clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    canvas.drawRect(holeRect, clearPaint);

    // 5) Restore back to the main canvas (the hole region will now be transparent):
    canvas.restore();

    // 6) Draw four blue corner decorations (“L” shapes) at holeRect corners:
    final double strokeWidth = 4.0;
    final double cornerLen = 30.0;
    final Paint cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Top-left corner:
    final Offset tl = holeRect.topLeft;
    canvas.drawLine(tl, Offset(tl.dx + cornerLen, tl.dy), cornerPaint);
    canvas.drawLine(tl, Offset(tl.dx, tl.dy + cornerLen), cornerPaint);

    // Top-right corner:
    final Offset tr = holeRect.topRight;
    canvas.drawLine(tr, Offset(tr.dx - cornerLen, tr.dy), cornerPaint);
    canvas.drawLine(tr, Offset(tr.dx, tr.dy + cornerLen), cornerPaint);

    // Bottom-left corner:
    final Offset bl = holeRect.bottomLeft;
    canvas.drawLine(bl, Offset(bl.dx + cornerLen, bl.dy), cornerPaint);
    canvas.drawLine(bl, Offset(bl.dx, bl.dy - cornerLen), cornerPaint);

    // Bottom-right corner:
    final Offset br = holeRect.bottomRight;
    canvas.drawLine(br, Offset(br.dx - cornerLen, br.dy), cornerPaint);
    canvas.drawLine(br, Offset(br.dx, br.dy - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.cornerColor != cornerColor ||
        oldDelegate.holeWidthFraction != holeWidthFraction;
  }
}

class _ScannerOverlay extends StatelessWidget {
  final double holeWidthFraction;
  final Color overlayColor;
  final Color cornerColor;

  const _ScannerOverlay({
    this.holeWidthFraction = 0.75,
    this.overlayColor = const Color(0x88000000),
    this.cornerColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ScannerOverlayPainter(
        holeWidthFraction: holeWidthFraction,
        overlayColor: overlayColor,
        cornerColor: cornerColor,
      ),
    );
  }
}

/// ============================
/// FLASHLIGHT BUTTON (v7.0.0 API)
/// ============================

class _FlashlightButton extends StatefulWidget {
  final MobileScannerController controller;
  const _FlashlightButton({required this.controller});

  @override
  State<_FlashlightButton> createState() => _FlashlightButtonState();
}

class _FlashlightButtonState extends State<_FlashlightButton> {
  bool _isTorchOn = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // 1) Toggle the physical torch:
        await widget.controller.toggleTorch();
        // 2) Invert our local boolean so the icon updates.
        //    (mobile_scanner 7.0.0 does not expose a torchState getter,
        //     so we assume toggleTorch() always succeeds.)
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(
          // Switch between on/off icons based on our local boolean:
          _isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
