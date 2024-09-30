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
  bool hasNavigated = false;

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
                  Text('Scan a code'),
                  const SizedBox(height: 16),
                  if (result != null) CircularProgressIndicator(),
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
        if (result != null && !hasNavigated) {
          try {
            int id = int.parse(result!.code!);
            hasNavigated = true;

            // Once the QR code is scanned, navigate to ArtworkView and pass the ID
            Navigator.pushNamed(
              context,
              Routes.artwork,
              arguments: {'id': id},
            ).then((_) {
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
