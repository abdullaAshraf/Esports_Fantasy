import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String username;
  String id;
  int balance;
  double points;
  DocumentReference roster;

  User();

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        id = json['id'],
        balance = json['balance'],
        points = json['points'].toDouble(),
        roster = json['roster'];
}
