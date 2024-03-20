import 'dart:convert';
import 'dart:core';

List<Users> postFromJsonUsers(String str) {
  return List<Users>.from(json.decode(str)['users'].map((x)=> Users.fromJson(x)));
}

class Users{
  String userId;
  String username;
  String? fullName;

  Users({
    required this.userId,
    required this.username,
    this.fullName,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    userId: json['id'],
    username: json['username'],
    fullName: json['name'] ?? json['username'],
  );
}