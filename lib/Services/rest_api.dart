import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soltwin_se2702/Services/getset_preferences.dart';

class APIServices{
  final String host = 'http://192.168.2.30:5000';
  //late String _sessionID;

  // You can set the session ID through the constructor or a separate method
  //APIServices(this._sessionID);

  Future<bool> matlabControl(String model, String? subModel, String command) async {
    http.Response response;

    if(subModel == null){
      response = await http.post(
          Uri.parse('$host/$model/command'),
          headers: {
            'Content-type':'application/json'
          },
          body: json.encode({
            'command': command
          })
      );
    }else{
      response = await http.post(
          Uri.parse('$host/$model/$subModel/command'),
          headers: {
            'Content-type':'application/json'
          },
          body: json.encode({
            'command': command
          })
      );
    }


    if (response.statusCode == 200) {
      // Handle success
      print('Success: ${response.body}');
      return true;
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  Future<void> setPID(String command, String target, double value) async {
    //command type as below:
    ////updatePID for setting value P, I and D
    ////changeSetPoint for changing sv
    ////updateConstant for changing mv
    http.Response response = await http.post(
        Uri.parse('$host/command'),
        headers: {
          'Content-type':'application/json'
        },
        body: json.encode({
          'command': command,
          target: value
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

  Future<void> switchManualMode() async {

    http.Response response = await http.post(
        Uri.parse('$host/command'),
        headers: {
          'Content-type':'application/json'
        },
        body: json.encode({
          'command': 'manual',
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

  Future<void> switchAutoMode() async {

    http.Response response = await http.post(
        Uri.parse('$host/command'),
        headers: {
          'Content-type':'application/json'
        },
        body: json.encode({
          'command': 'auto',
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

  Future<bool> loginReq(String username, String password) async {
    http.Response response = await http.post(
        Uri.parse('$host/auth/login'),
        body: {
          'username': username,
          'password': password
        }
    );
    if(response.statusCode == 200) {
      print('Login Successfully');
      final responseJson = jsonDecode(response.body);
      String userID = responseJson['userID'].toString();

      ///Saved token for further used
      print(userID);
      await setUserID(userID);
      return true;
    }
    else{
      print('Wrong Username or Password');
      return false;
    }
  }

}