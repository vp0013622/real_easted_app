// ignore_for_file: file_names

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class InternetConnection {
  final _connectivity = Connectivity();

  Future<bool> checkInternetConnection() async {
    try {
      // First check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Then verify actual internet connection with a reliable endpoint
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Stream<bool> monitorInternetConnection() {
    return _connectivity.onConnectivityChanged.asBroadcastStream().map(
      (result) => result != ConnectivityResult.none,
    );
  }

  Future<bool> hasStableConnection() async {
    try {
      // Check multiple times to ensure stable connection
      for (var i = 0; i < 2; i++) {
        final hasConnection = await checkInternetConnection();
        if (!hasConnection) return false;
        await Future.delayed(const Duration(milliseconds: 500));
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
