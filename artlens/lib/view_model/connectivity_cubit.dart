import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {}

class ConnectivityOffline extends ConnectivityState {}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityCubit() : super(ConnectivityOnline()) {
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      // Verificamos si la lista contiene `ConnectivityResult.none` para detectar falta de conexión
      if (results.contains(ConnectivityResult.none)) {
        emit(ConnectivityOffline());
        print("No connection"); // Log para confirmar desconexión
      } else {
        emit(ConnectivityOnline());
        print("Connected"); // Log para confirmar conexión
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
