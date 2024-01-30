import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Service {
  final baseUrl = dotenv.get("BASE_URL_API", fallback: "");

  Future<bool> postLogin(String username, String password, String secretKey,
      String checksum) async {
    var response = await http.post(Uri.parse("$baseUrl//api/users"),
        body: jsonEncode({
          "username": username,
          "password": password,
          "secret_key": secretKey,
          "check_sum": checksum
        }));

    if (response.statusCode == 201) {
      print("Login Success");
      return true;
    }
    print(response.statusCode);
    return false;
  }
}
