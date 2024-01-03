import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkStatusProvider extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _isConnected = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }
}
