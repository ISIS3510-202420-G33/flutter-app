import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importa el paquete de conectividad
import '../routes.dart';

class FakeSearchBar extends StatefulWidget {
  const FakeSearchBar({Key? key}) : super(key: key);

  @override
  _FakeSearchBarState createState() => _FakeSearchBarState();
}

class _FakeSearchBarState extends State<FakeSearchBar> {
  bool _canShowError = true; // Bandera para controlar el intervalo de tiempo entre mensajes

  Future<void> _checkConnectivityAndNavigate(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult[0] != ConnectivityResult.none;

    if (isOnline) {
      Navigator.pushNamed(context, Routes.searchResults, arguments: ""); // Navega si hay conexión
    } else if (_canShowError) {
      // Muestra un SnackBar si no hay conexión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _canShowError = false; // Bloquea el próximo mensaje de error
      });

      // Restablece la bandera después de 2 segundos
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _canShowError = true; // Permite mostrar el mensaje de error nuevamente
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _checkConnectivityAndNavigate(context), // Llama al método para verificar conexión
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Search for artwork, artist, or museum",
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
            Icon(Icons.search, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
