import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/barcode_utils.dart';

class BarcodeScannerDialog extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerDialog({
    Key? key,
    required this.onBarcodeScanned,
  }) : super(key: key);

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog>
    with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  String? _scannedBarcode;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
          _animationController.forward();
        }
      });

    _animationController.forward();
    _startScan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scannedBarcode = null;
      _error = null;
    });

    try {
      final barcode = await BarcodeUtils.scanBarcode(context);

      if (mounted) {
        setState(() {
          _isScanning = false;
          _scannedBarcode = barcode;
        });

        if (barcode != null) {
          widget.onBarcodeScanned(barcode);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _error = 'Error scanning barcode: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Barcode Scanner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),

            // Scanner content
            if (_isScanning) ...[
              // Scanner animation
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Camera view placeholder
                    Container(
                      width: 280,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),

                    // Scan line animation
                    Positioned(
                      top: _animation.value * 160,
                      child: Container(
                        width: 260,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Target corners
                    Positioned(
                      child: Container(
                        width: 220,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Position barcode within the frame',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scanning...',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (_scannedBarcode != null) ...[
              // Scanned result
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Barcode Scanned Successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _scannedBarcode!,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Type: ${BarcodeUtils.getBarcodeType(_scannedBarcode!)}',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
            ] else if (_error != null) ...[
              // Error state
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Scanning Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isScanning)
                  OutlinedButton(
                    onPressed: _startScan,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Scan Again'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _scannedBarcode != null
                        ? Colors.green
                        : AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(_scannedBarcode != null ? 'Done' : 'Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a barcode scanner dialog
Future<String?> showBarcodeScannerDialog(BuildContext context) async {
  String? barcode;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return BarcodeScannerDialog(
        onBarcodeScanned: (scannedBarcode) {
          barcode = scannedBarcode;
        },
      );
    },
  );

  return barcode;
}
