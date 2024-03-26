import 'package:shared_preferences/shared_preferences.dart';

const String isDarkMode = 'isDarkMode';
const String prefUserID = 'userID';
const String rememberMeString = 'rememberMe';
const String savedUsername = 'savedUsername';
const String savedPassword = 'savedPassword';

///Set User Token to Shared Preferences
setUserID(String id) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(prefUserID, id);
}
///Get User Token from Shared Preferences
Future<String> getUserID() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(prefUserID) ?? 'id';
  return value;
}

///Set User Remember Me to Shared Preferences
setRememberMe(bool rememberMe, String username, String password) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(rememberMeString, rememberMe);
  await prefs.setString(savedUsername, username);
  await prefs.setString(savedPassword, password);
}

///Get User saved username from Shared Preferences
Future<String> getSavedUsername() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(savedUsername)??'Username';
  return value;
}

///Get User saved password from Shared Preferences
Future<String> getSavedPassword() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(savedPassword) ?? 'Password';
  return value;
}