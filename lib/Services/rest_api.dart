import 'dart:convert';
import 'package:http/http.dart' as http;

class APIServices{
  final String _baseURL = 'http://localhost:5000';
  //late String _sessionID;

  // You can set the session ID through the constructor or a separate method
  //APIServices(this._sessionID);

  Future<void> startMatlab() async {
    http.Response response = await http.post(
        Uri.parse('$_baseURL/command'),
        headers: {
          'Content-type':'application/json'
        },
        body: json.encode({
          'command': 'start'
        })
    );

    if (response.statusCode == 200) {
      // Handle success
      print('Success: ${response.body}');
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> stopMatlab() async {
    http.Response response = await http.post(
        Uri.parse('$_baseURL/command'),
        headers: {
          'Content-type':'application/json'
        },
        body: json.encode({
          'command': 'stop'
        })
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