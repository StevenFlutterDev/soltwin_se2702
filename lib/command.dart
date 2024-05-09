import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const String url = 'http://192.168.1.102:9901/se270smarchieve/se270';
  var payload = {'nargout': 0, 'rhs': []};
  var headers = {'Content-Type': 'application/json'};

  // Send the POST request
  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: json.encode(payload),
  );

  // Check the response status code
  if (response.statusCode == 200) {
    print('Request successful. Response:');
    print(response.body);
  } else {
    print('Request failed with status code ${response.statusCode}.');
  }
}