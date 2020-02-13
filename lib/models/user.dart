import './roster.dart';

class User {
  String username;
  String id;
  int balance;
  double points;
  String roster;

  User();

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        id = json['id'],
        balance = json['balance'],
        points = json['points'],
        roster = json['roster'];
}
