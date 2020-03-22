import 'package:html_unescape/html_unescape.dart';
import '../models/playerAttachment.dart';

class Player {
  String id;
  String name;
  String originalName;
  String tag;
  String image;
  String country;
  int age;
  String team;
  String role;
  String tournament;
  double points;
  int price;
  PlayerAttachment attachment;

  Player();

  Player.card(String tag, double points, String role, String team)
      : tag = tag,
        points = points,
        originalName = "",
        role = role,
        team = team {
    id = tag + '(' + originalName + ')';
  }

  Player.empty()
      : tag = "",
        points = 0.0,
        role = "",
        team = "",
        id = "none";

  Player.fromJson(Map<String, dynamic> json)
      : name = new HtmlUnescape().convert(json['Name']).replaceAll("&nbsp;", " "),
        originalName = json['Name'],
        tag = json['ID'],
        image = json['Image'],
        country = json['Country'],
        age = int.tryParse(json['Age']) ?? 0,
        team = json['Team'],
        role = json['Role'].toLowerCase(),
        tournament = json['Tournament'],
        points = 0,
        attachment = null,
        price = 0 {
    id = tag + '(' + originalName + ')';
  }
}
