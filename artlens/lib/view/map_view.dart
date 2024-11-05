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
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<
      GoogleMapController>();
  static const LatLng _pUniversidadAndes = LatLng(
      4.603104981314923, -74.06507505903969);
  LatLng? _currentP;
  Set<Marker> _museumMarkers = {};
  int _selectedIndex = 0;
  bool isOnline = true;
  bool isFetched = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }


  Future<void> _initializeConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult[0] != ConnectivityResult.none;
    if (isOnline) {
      isFetched = true;
      getLocationUpdates();
    } else {
      if (isFetched) {
        setState(() {
          isOnline;
        });
      } else {
        getLocationUpdates();
      }
    }
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

    _locationController.onLocationChanged.listen((
        LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
          fetchMuseums(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  Future<void> fetchMuseums(double latActual, double longActual) async {
    if (!isOnline) return;

    try {
      final museums = await widget.appFacade.fetchMuseums(
          latActual, longActual);
      setState(() {
        _museumMarkers = museums.map((museum) {
          return Marker(
            markerId: MarkerId(museum.id.toString()),
            position: LatLng(
                double.parse(museum.latitude), double.parse(museum.longitude)),
            infoWindow: InfoWindow(title: museum.name),
          );
        }).toSet();
      });
    } catch (e) {
      print('Error fetching museums: $e');
    }
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 14);
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } else if (index == 1) {
      Navigator.pushNamed(context, Routes.camera);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Map"),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ConnectivityCubit, ConnectivityState>(
            listener: (context, connectivityState) {
              if (connectivityState is ConnectivityOffline) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Connection lost. Some features may not be available.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (connectivityState is ConnectivityOnline) {
                _cameraToPosition(_currentP!);
                getLocationUpdates();
                fetchMuseums(_currentP!.latitude, _currentP!.longitude);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connection restored.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, connectivityState) {
            bool isOnline = connectivityState is ConnectivityOnline;

            return isOnline
                ? (_currentP == null
                ? const Center(child: Text("Loading..."))
                : GoogleMap(
              onMapCreated: (controller) => _mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target: _currentP!,
                zoom: 14,
              ),
              markers: _museumMarkers,
              circles: _currentP != null
                  ? {
                Circle(
                  circleId: CircleId("_currentLocationCircle"),
                  center: _currentP!,
                  radius: 50,
                  fillColor: Colors.blue.withOpacity(0.5),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
              }
                  : {},
            ))
                : const Center(child: Text("No internet connection."));
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