import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';
import 'auth_service.dart';

class BarangService {
  static const String baseUrl = 'http://192.168.1.2:8000/api';

  static Future<List<Barang>> fetchBarangs() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/barangs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'];

      return data.map((item) => Barang.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data barang');
    }
  }
}
