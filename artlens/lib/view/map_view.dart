import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/custom_app_bar.dart';
import '../routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../view_model/facade.dart';
import '../view_model/connectivity_cubit.dart';

class MapView extends StatefulWidget {
  final AppFacade appFacade;

  const MapView({
    Key? key,
    required this.appFacade,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _currentP;
  Set<Marker> _museumMarkers = {};
  int _selectedIndex = 0;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      await _ensureLocationPermission();
      _listenToLocationChanges();
    }
  }

  Future<void> _ensureLocationPermission() async {
    final serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      final serviceRequested = await _locationController.requestService();
      if (!serviceRequested) return;
    }

    var permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }
  }

  void _listenToLocationChanges() {
    _locationController.onLocationChanged.listen((currentLocation) {
      final latitude = currentLocation.latitude;
      final longitude = currentLocation.longitude;

      if (latitude != null && longitude != null) {
        final position = LatLng(latitude, longitude);

        if (_currentP == null || _currentP != position) {
          _currentP = position;
          _updateCameraPosition(position);
          _fetchMuseums(latitude, longitude);
        }
      }
    });
  }

  Future<void> _fetchMuseums(double latitude, double longitude) async {
    if (!isOnline) return;

    try {
      final museums = await widget.appFacade.fetchMuseums(latitude, longitude);
      setState(() {
        _museumMarkers = museums.map((museum) {
          return Marker(
            markerId: MarkerId(museum.id.toString()),
            position: LatLng(double.parse(museum.latitude), double.parse(museum.longitude)),
            infoWindow: InfoWindow(title: museum.name),
          );
        }).toSet();
      });
    } catch (e) {
      debugPrint('Error fetching museums: $e');
    }
  }

  Future<void> _updateCameraPosition(LatLng position) async {
    final controller = await _mapController.future;
    final cameraPosition = CameraPosition(target: position, zoom: 14);
    await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    final route = index == 0 ? Routes.home : Routes.camera;
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Map"),
      body: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: (context, connectivityState) {
          if (connectivityState is ConnectivityOffline) {
            isOnline = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connection lost. Some features may not be available.'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (connectivityState is ConnectivityOnline) {
            isOnline = true;
            if (_currentP != null) {
              _updateCameraPosition(_currentP!);
              _fetchMuseums(_currentP!.latitude, _currentP!.longitude);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connection restored.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: _currentP == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
          onMapCreated: (controller) => _mapController.complete(controller),
          initialCameraPosition: CameraPosition(target: _currentP!, zoom: 14),
          markers: _museumMarkers,
          circles: {
            Circle(
              circleId: const CircleId("_currentLocationCircle"),
              center: _currentP!,
              radius: 50,
              fillColor: Colors.blue.withOpacity(0.5),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
