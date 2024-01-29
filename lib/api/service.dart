import 'dart:convert';
import 'package:http/http.dart' as http;

class Service {
  final baseUrl =
      "https://reqres.in"; //TODO: change when API is up or put on env

  Future<bool> postLogin(String username, String password, String secretKey,
      String checksum) async {
    var response = await http.post(
        Uri.parse(
            "$baseUrl/api/users"), //TODO: change when API is up or put on env
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
    return false;
  }
}
