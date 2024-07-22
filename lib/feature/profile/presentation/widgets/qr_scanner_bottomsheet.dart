import 'dart:convert'; // Import this for JSON encoding

import 'package:flutter/material.dart';
import 'package:meechat/utils/styles.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerBottomSheet extends StatefulWidget {
  final void Function(String code) onRoomCreated;

  const QRScannerBottomSheet({
    super.key,
    required this.onRoomCreated,
  });

  @override
  State<StatefulWidget> createState() => _QRScannerBottomSheetState();
}

class _QRScannerBottomSheetState extends State<QRScannerBottomSheet> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _isScanningPaused = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Scanner',
          style: blackTextStyle.merge(semiBoldStyle),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Text(
                'Scan a code',
                style: whiteTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    // Pause scanning if needed
    if (_isScanningPaused) {
      controller.pauseCamera();
    }

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if (_isValidQRCode(scanData.code)) {
        // Pause scanning
        controller.pauseCamera();
        // Close the bottom sheet
        Navigator.of(context).pop();

        // Run the createRoom function
        widget.onRoomCreated(scanData.code!);
      } else {
        // Pause scanning
        controller.pauseCamera();
        // Show an alert dialog if the QR code is not valid
        _showInvalidQRCodeAlert();
      }
    });
  }

  bool _isValidQRCode(String? code) {
    if (code == null) return false;
    try {
      final Map<String, dynamic> data = jsonDecode(code);
      return data.containsKey('id') &&
          data.containsKey('firstName') &&
          data.containsKey('lastName');
    } catch (e) {
      return false;
    }
  }

  void _showInvalidQRCodeAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid QR Code'),
          content: const Text('The scanned QR code is invalid.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isScanningPaused = false;
                });
                controller?.resumeCamera(); // Resume scanning
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
