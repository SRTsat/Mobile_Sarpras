import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AuthProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  String? _token;

  String? get token => _token;

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); // ganti dengan IP Laravel kalau pakai emulator
    final response = await http.post(
      url,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      _token = body['access_token'];
      await storage.write(key: 'token', value: _token);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
