import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // contains baseUrl

class ApiService {
  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/accounts/login/');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Login Success: ${response.body}");
    } else {
      print("❌ Login Failed: ${response.statusCode}");
      print("🔍 Error: ${response.body}");
    }
  }
}
