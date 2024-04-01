import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/Services/getset_preferences.dart';
import 'package:soltwin_se2702/main.dart';

class APIServices{
  final String host = 'http://192.168.2.30:8000';
  //late String _sessionID;

  // You can set the session ID through the constructor or a separate method
  //APIServices(this._sessionID);

  Future<bool> matlabControl(String model, String? subModel, String command) async {
    var token = await getUserToken();
    http.Response response;
    try{
      if(subModel == null) {
        response = await http.post(
            Uri.parse('$host/$model/command/'),
            headers: {
              'Content-type': 'application/json',
              'Authorization':'Token $token'
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
              'Authorization':'Token $token'
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
              'Authorization':'Token $token'
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
              'Authorization':'Token $token'
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

  Future<void> switchManualMode() async {
    var token = await getUserToken();
    try{
      http.Response response = await http.post(
          Uri.parse('$host/command/'),
          headers: {
            'Content-type':'application/json',
            'Authorization':'Token $token'
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
    }catch (e){
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (context)=>ShareMessageDialog(contentMessage: e.toString()));
    }

  }

  Future<void> switchAutoMode() async {
    var token = await getUserToken();
    try{
      http.Response response = await http.post(
          Uri.parse('$host/command/'),
          headers: {
            'Content-type':'application/json',
            'Authorization':'Token $token'
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
    }catch (e){
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (context)=>ShareMessageDialog(contentMessage: e.toString()));
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
        String token = responseJson['token'].toString();

        ///Saved token for further used
        print(token);
        await setUserToken(token);

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

}