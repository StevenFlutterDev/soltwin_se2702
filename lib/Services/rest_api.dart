import 'dart:convert';
import 'package:http/http.dart' as http;

class APIServices{
  final String _baseURL = 'http://127.0.0.1';
  late String _sessionID;

  // You can set the session ID through the constructor or a separate method
  APIServices(this._sessionID);

  Future<void> postValue(double p) async {
    Uri uri = Uri.parse('$_baseURL/$_sessionID/p');
    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'p': p}),
    );

    if (response.statusCode == 200) {
      // Handle success
      print('Success: ${response.body}');
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }
}