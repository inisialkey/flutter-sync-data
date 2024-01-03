// api_service.dart
import 'dart:convert';

import 'package:flutter_offline/user.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> sendUserToServer(User user) async {
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImlhdCI6MTcwNDI3MDk1NCwiZXhwIjoxNzA1OTk4OTU0fQ.s7xBnC1sS5b8o648c_R1_a8X94vnp6FD-p1eFBmJzz0';
    final response = await http.post(
      Uri.parse('https://api.escuelajs.co/api/v1/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toMap()),
    );
    print('panggil');
    print(response.body);
    print(response.statusCode);
    print('Mengirim data ke server: ${user.toMap()}');
  }
}
