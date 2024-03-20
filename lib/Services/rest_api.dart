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

  ///Post Login
  Future<bool> loginReq(String username, String password) async {
    http.Response response = await http.post(
        Uri.parse('$_baseURL/auth/login'),
        body: {
          'username': username,
          'password': password
        }
    );

    if(response.statusCode == 200) {
      print('Login Successfully');
      final responseJson = jsonDecode(response.body);
      String retrieveToken = responseJson['token'].toString();
      String retrieveUsername = responseJson['user']['username'].toString();

      /*///Saved token for further used
      print(retrieveToken);
      setUserToken(retrieveToken);

      Provider.of<UserInfoProvider>(NavigationService.navigatorKey.currentContext!,listen: false).setUserFullName(retrieveUsername);
      Provider.of<UserInfoProvider>(NavigationService.navigatorKey.currentContext!,listen: false).setUserRoles(retrieveRole);
      print(Provider.of<UserInfoProvider>(NavigationService.navigatorKey.currentContext!,listen: false).userFullName);
      print(Provider.of<UserInfoProvider>(NavigationService.navigatorKey.currentContext!,listen: false).userRole);*/
      return true;

    }
    else{
      print('Wrong Username or Password');
      return false;
    }
  }

}