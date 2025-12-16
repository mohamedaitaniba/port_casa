import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    // Check initial status
    final result = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection([result]);
    _connectionController.add(_isConnected);

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      final connected = _hasConnection([result]);
      if (connected != _isConnected) {
        _isConnected = connected;
        _connectionController.add(_isConnected);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection([result]);
    return _isConnected;
  }

  void dispose() {
    _connectionController.close();
  }
}

