import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String tag;
  String champion;
  int kills;
  int deaths;
  int assists;
  int gold;
  int cs;
  bool win;
  String role;
  Timestamp time;
  double length;
  int roundNumber;

  Game();

  Game.fromJson(Map<String, dynamic> json)
      : tag = json['title']['Name'],
        champion = json['title']['Champion'],
        kills = int.tryParse(json['title']['Kills']),
        deaths = int.tryParse(json['title']['Deaths']),
        assists = int.tryParse(json['title']['Assists']),
        gold = int.tryParse(json['title']['Gold']),
        cs = int.tryParse(json['title']['CS']),
        win = json['title']['PlayerWin'] == "Yes",
        role = json['title']['Role'],
        time = Timestamp.fromDate(DateTime.parse(json['title']['DateTime UTC'])),
        length = double.tryParse(json['title']['Gamelength Number']),
        roundNumber = int.tryParse(json['title']['N GameInMatch']);
}
