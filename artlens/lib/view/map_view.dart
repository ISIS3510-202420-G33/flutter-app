import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../widgets/custom_app_bar.dart';
import '../routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../view_model/facade.dart';


class MapView extends StatefulWidget {
  final AppFacade appFacade;

  const MapView({
    Key? key,
    required this.appFacade,
  }) : super(key:key);


  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  static const LatLng _pUniversidadAndes = LatLng(4.603104981314923, -74.06507505903969);
  static const LatLng _pMuseoDelOro = LatLng(4.602126680305319, -74.07205183368727);
  static const LatLng _pMuseoNacional = LatLng(4.615551, -74.068818);
  static const LatLng _pMuseoBotero = LatLng(4.598250, -74.075624);
  static const LatLng _pCasaDeMoneda = LatLng(4.598900, -74.075668);
  static const LatLng _pMambo = LatLng(4.611277, -74.070438);
  static const LatLng _pMuseoDeBogota = LatLng(4.599825, -74.076156);
  static const LatLng _pMuseoColonial = LatLng(4.602019, -74.071960);
  static const LatLng _pMuseoEsmeralda = LatLng(4.601464, -74.068297);
  static const LatLng _pMuseoSantaClara = LatLng(4.597944, -74.072523);
  static const LatLng _pPlanetarioBogota = LatLng(4.609710, -74.070089);

  LatLng? _currentP = null;
  int _selectedIndex = 0; // Para manejar el índice del BottomNavigationBar

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }
  Set<Marker> _museumMarkers = {};


  Future<void> fetchMuseums(double latActual, double longActual) async {
    try {
      print("Actual position");
      print(latActual);
      print(longActual);
      print("Fetching museums...");  // Add this line
      final museums = await widget.appFacade.fetchMuseums(latActual, longActual);

      _museumMarkers.clear();
      for (var museum in museums) {
        double lat = double.parse(museum.latitude);
        double long = double.parse(museum.longitude);
        LatLng position = LatLng(lat, long);
        print(position);

        _museumMarkers.add(Marker(
          markerId: MarkerId(museum.id.toString()),
          icon: BitmapDescriptor.defaultMarker,
          position: position,
          infoWindow: InfoWindow(title: museum.name),
        ));
      }
      print("Museums updated");
      setState(() {});
    } catch (e) {
      print('Error fetching museums: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Map"),
      body: _currentP == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
        initialCameraPosition: CameraPosition(target: _pUniversidadAndes, zoom: 14),
        markers: _museumMarkers,
        circles: _currentP == null
            ? {}
            : {
          Circle(
            circleId: CircleId("_currentLocationCircle"),
            center: _currentP!,
            radius: 50, // Puedes ajustar el tamaño del círculo aquí
            fillColor: Colors.blue.withOpacity(0.5), // Color del círculo
            strokeColor: Colors.blue, // Color del borde del círculo
            strokeWidth: 2, // Grosor del borde
          ),
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 14);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
          fetchMuseums(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  // Define a function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else if (index == 1) {
        Navigator.pushNamed(context, Routes.camera);
      } else if (index == 2) {
        Navigator.pushNamed(context, Routes.trending);
      }
    });
  }
}
