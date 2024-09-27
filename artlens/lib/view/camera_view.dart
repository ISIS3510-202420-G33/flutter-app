import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../routes.dart';
import '../widgets/custom_app_bar.dart';

class CameraPreviewScreen extends StatefulWidget {
  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrController;
  bool hasNavigated = false; // Flag to track if navigation has already occurred

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "QR Scanner"),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Scan a code'), // This text will always be visible
                  const SizedBox(height: 16), // Adds some space between text and loader
                  if (result != null) CircularProgressIndicator(), // Show only when processing the QR code
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.qrController = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null && !hasNavigated) { // Check if we haven't navigated yet
          // Check if the result is a valid integer string
          try {
            int id = int.parse(result!.code!); // Convert the scanned code to an int
            hasNavigated = true; // Set flag to prevent further navigation

            // Once the QR code is scanned, navigate to ArtworkView and pass the ID
            Navigator.pushNamed(
              context,
              Routes.artwork,
              arguments: {'id': id},
            ).then((_) {
              // Reset the flag once we return from ArtworkView
              setState(() {
                hasNavigated = false;
              });
            });
          } catch (e) {
            print('Error converting QR code to int: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid QR code format')),
            );
          }
        }
      });
    });
  }
}
