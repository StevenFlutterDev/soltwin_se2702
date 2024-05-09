import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/Services/getset_preferences.dart';
import 'package:soltwin_se2702/main.dart';

class APIServices{
  final String host = 'http://192.168.1.102:8000';
  //late String _sessionID;

  // You can set the session ID through the constructor or a separate method
  //APIServices(this._sessionID);

  //Start or Stop Matlab Computing
  Future<bool> matlabControl(String model, String? subModel, String command) async {
    var token = await getUserToken();
    http.Response response;
    try{
      if(subModel == null) {
        response = await http.post(
            Uri.parse('$host/$model/command/'),
            headers: {
              'Content-type': 'application/json',
              'Authorization':'Bearer $token'
            },
            body: json.encode({
              'command': command
            })
        );
      } else {
        response = await http.post(
            Uri.parse('$host/$model/$subModel/command/'),
            headers: {
              'Content-type':'application/json',
              'Authorization':'Bearer $token'
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
    }catch(e){
      showDialog(context: NavigationService.navigatorKey.currentContext!, builder: (context)=> ShareMessageDialog(contentMessage: e.toString()));
      return false;
    }
  }

  Future<void> setValueCommand(String model, String? subModel, String command, String target, double value) async {
    //command type as below:
    ////updatePID for setting value P, I and D
    ////changeSetPoint for changing sv
    ////updateConstant for changing mv
    var token = await getUserToken();
    http.Response response;
    try{
      if(subModel == null) {
        response = await http.post(
            Uri.parse('$host/$model/command/'),
            headers: {
              'Content-type':'application/json',
              'Authorization':'Bearer $token'
            },
            body: json.encode({
              'command': command,
              target: value
            })
        );
      }else{
        response = await http.post(
            Uri.parse('$host/$model/$subModel/command/'),
            headers: {
              'Content-type':'application/json',
              'Authorization':'Bearer $token'
            },
            body: json.encode({
              'command': command,
              target: value
            })
        );
      }

      if (response.statusCode == 200) {
        // Handle success
        print('Success: ${response.body}');
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
      }
    }catch (e){
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (context)=>ShareMessageDialog(contentMessage: e.toString()));
    }
  }

  Future<bool> setControlCommand(String model, String? subModel, String command) async {
    //Set Auto or Manual Mode use this function
    var token = await getUserToken();
    http.Response response;
    try{
      if(subModel == null) {
        response = await http.post(
            Uri.parse('$host/$model/command/'),
            headers: {
              'Content-type':'application/json',
              'Authorization':'Bearer $token'
            },
            body: json.encode({
              'command': command,
            })
        );
      }else{
        response = await http.post(
            Uri.parse('$host/$model/$subModel/command/'),
            headers: {
              'Content-type':'application/json',
              'Authorization':'Bearer $token'
            },
            body: json.encode({
              'command': command,
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
    }catch (e){
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (context)=>ShareMessageDialog(contentMessage: e.toString()));
      return false;
    }
  }

  Future<bool> loginReq(String username, String password) async {

    try{
      http.Response response = await http.post(
          Uri.parse('$host/auth/login/'),
          body: {
            'username': username,
            'password': password
          }
      );
      if(response.statusCode == 200) {
        print('Login Successfully');
        final responseJson = jsonDecode(response.body);
        String token = responseJson['access'].toString();
        String userID = responseJson['user_id'].toString();
        String port = responseJson['port'].toString();

        ///Saved token for further used
        print(token);
        await setUserDetails(token, userID, port);

        print(true);
        return true;
      }
      else{
        print('Wrong Username or Password');
        return false;
      }
    }catch (e){
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (context)=>ShareMessageDialog(contentMessage: e.toString()));
      return false;
    }

  }

  Future<bool> runSE2702Model() async {
    final String portNumber = await getPortNumber();
    final String id = await getUserID();
    final String url = 'http://192.168.1.102:$portNumber/se270smarchieve/se270';
    var payload = {'nargout': 0, 'rhs': [id]};
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
      return true;
    } else {
      print('Request failed with status code ${response.statusCode}.');
      return false;
    }
  }

  Future<bool> runHE104COModel() async {
    String modelUrl = 'http://192.168.1.102:9900/he104cocurrentarchieve/main';
    try{
      http.Response response = await http.post(
          Uri.parse(modelUrl),
          headers: {
            'Content-Type' : 'application/json'
          },
          body: json.encode({'nargout': 0, 'rhs': []})
      );
      if(response.statusCode == 200) {
        print('HE104 CO Current start successfully');

        return true;
      }
      else{
        print('HE104 CO Current failed to start');
        return false;
      }
    }catch (e){
      print(e.toString());
      return false;
    }

  }

  Future<bool> runHE104CounterModel() async {
    String modelUrl = 'http://192.168.1.102:9900/he104countercurrentarchieve/run';
    try{
      http.Response response = await http.post(
          Uri.parse(modelUrl),
          headers: {
            'Content-Type' : 'application/json'
          },
          body: json.encode({
            'nargout': 0,
            'rhs': []
          })
      );
      if(response.statusCode == 200) {
        print('SE2702 start successfully');

        return true;
      }
      else{
        print('SE2702 start failed');
        return false;
      }
    }catch (e){
      print(e.toString());
      return false;
    }

  }

}