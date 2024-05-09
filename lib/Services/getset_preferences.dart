import 'package:shared_preferences/shared_preferences.dart';

const String isDarkMode = 'isDarkMode';
const String prefUserToken = 'userToken';
const String prefUserID = 'userID';
const String prefPortNum = '0';
const String rememberMeString = 'rememberMe';
const String savedUsername = 'savedUsername';
const String savedPassword = 'savedPassword';

///Set User Token to Shared Preferences
setUserDetails(String token, String userID, String portNumber) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(prefUserToken, token);
  await prefs.setString(prefUserID, userID);
  await prefs.setString(prefPortNum, portNumber);
}
///Get User Token from Shared Preferences
Future<String> getUserToken() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(prefUserToken) ?? 'token';
  return value;
}
Future<String> getUserID() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(prefUserID) ?? 'userID';
  return value;
}
Future<String> getPortNumber() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(prefPortNum) ?? '0';
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