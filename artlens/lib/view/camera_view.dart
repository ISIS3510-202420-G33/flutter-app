import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../entities/artwork.dart';
import '../model/artwork_service.dart';
import '../routes.dart';
import '../widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/firestore_service.dart';

class CameraPreviewScreen extends StatefulWidget {
  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrController;
  bool hasNavigated = false;
  final FirestoreService _firestoreService = FirestoreService();
  late final ArtworkService artworkService;

  @override
  void initState() {
    super.initState();
    artworkService = ArtworkService(); // Inicializa el servicio aquí
  }

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

    controller.scannedDataStream.listen((scanData) async {
      setState(() async {
        result = scanData;
        if (result != null && !hasNavigated) {
          try {
            int id = int.parse(result!.code!);
            hasNavigated = true;

            try {
              // Obtener el usuario desde SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              final username = prefs.getString('userName');
              DateTime date = DateTime.now();

              Artwork artwork = await artworkService.fetchArtworkById(id);
              final museum = artwork.museum;

              // Guardar la información en Firestore
              await _firestoreService.addDocument('BQ51', {
                'Usuario': username,
                'Fecha': date,
                'Museo': museum,
              });
            } catch (e) {
              print('Error adding document to Firebase: $e');
            }

            // Navegar a `ArtworkView` y pasar el ID
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
