import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  Location _locationController = new Location();

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

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: _currentP == null ? const Center(child: Text("Loading..."),) :
        GoogleMap(
          onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
          initialCameraPosition: CameraPosition(target: _pUniversidadAndes, zoom:14),
        markers: {
          Marker(
              markerId: MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _currentP!),
          Marker(
            markerId: MarkerId("_universidadDeLosAndes"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pUniversidadAndes),
          Marker(
              markerId: MarkerId("_museoDelOro"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pMuseoDelOro),
          Marker(
            markerId: MarkerId("_museoNacional"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pMuseoNacional),
          Marker(
            markerId: MarkerId("_museoBotero"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pMuseoBotero),
          Marker(
              markerId: MarkerId("_casaDeMoneda"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pCasaDeMoneda),
          Marker(
              markerId: MarkerId("_mambo"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pMambo),
          Marker(
              markerId: MarkerId("_museoDeBogota"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pMuseoDeBogota),
          Marker(
              markerId: MarkerId("_museoColonial"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pMuseoColonial),
          Marker(
              markerId: MarkerId("_museoEsmeralda"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pMuseoEsmeralda),
          Marker(
              markerId: MarkerId("_museoSantaClara"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pMuseoSantaClara),
          Marker(
              markerId: MarkerId("_planetarioBogota"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pPlanetarioBogota),
        },));
  }

  Future<void> _cameraToPosition(LatLng pos) async{
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 14);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else{
      return;
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted){
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null){
        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }
}
