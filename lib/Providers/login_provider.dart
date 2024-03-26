
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginProvider extends ChangeNotifier{

  bool isLoggedIn = false;

  Future<bool> getLoggedIn() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('isLogged') ?? false;
  }

  bool get currLoginStatus{
    return isLoggedIn;
  }

  void setUserLogin(bool isLogin){
    isLoggedIn = isLogin;
    notifyListeners();
  }


}
