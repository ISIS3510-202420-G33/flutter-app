import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../entities/artwork.dart';
import '../model/artwork_service.dart';
import '../routes.dart';
import '../widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/firestore_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


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
  bool isOnline = true;
  bool isFetched = false;
  bool isOfflineMessageShown = false;

  @override
  void initState() {
    super.initState();
    artworkService = ArtworkService();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    // Verifica la conectividad inicial
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOnline = connectivityResult[0] != ConnectivityResult.none;
    });

    // Escucha los cambios de conectividad
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        isOnline = connectivityResult[0] != ConnectivityResult.none;
      });
    });
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
                  Text(isOnline ? 'Scan a code' : 'No internet connection'),
                  const SizedBox(height: 16),
                  if (!isOnline) // Si no hay internet, muestra el mensaje
                    Icon(Icons.wifi_off, color: Colors.red),
                  if (result != null && isOnline) CircularProgressIndicator(),
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
      if (!isOnline) {
        if (!isOfflineMessageShown) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No internet connection. QR scan disabled.')),
          );
          isOfflineMessageShown = true;

          // Espera 3 segundos antes de permitir que el mensaje se vuelva a mostrar
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              isOfflineMessageShown = false;
            });
          });
        }
        return;
      }
      // Proceder con el escaneo solo si hay conexión
      result = scanData;
      if (result != null && isOnline && !hasNavigated) {
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
  }
}
