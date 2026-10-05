import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String url = "https://script.google.com/macros/s/AKfycbywxurp0-yCJHmmih9cm7ugebundNxUk4b9RYyIvBC-3Kiswlj8Hv1cb7UIqU31sS5Z/exec";

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "login", "username": username, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Menambahkan parameter opsional kelas untuk memfilter data siswa
  static Future<List<dynamic>> getData(String sheetName, String kodeLembaga, {String? pemberi, String? kelas}) async {
    try {
      String queryUrl = "$url?sheet=$sheetName&lembaga=$kodeLembaga";
      if (pemberi != null && pemberi.isNotEmpty) {
        queryUrl += "&pemberi=$pemberi";
      }
      if (kelas != null && kelas.isNotEmpty) {
        queryUrl += "&kelas=$kelas";
      }
      final response = await http.get(Uri.parse(queryUrl));
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addData(String sheetName, List<dynamic> values) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "addData", "sheet": sheetName, "values": values}),
      );
      var res = jsonDecode(response.body);
      return res['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}