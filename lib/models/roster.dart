import 'package:cloud_firestore/cloud_firestore.dart';

import './player.dart';
import '../services/api.dart';

HttpService httpService = HttpService();

class Roster {
  static const roles = ['top', 'jungler', 'mid', 'bot', 'support'];
  Map<String, RosterPlayer> players = new Map();
  List<Future<Player>> subs = [];

  Roster();

  Roster.data(DocumentSnapshot doc) {
    var data = doc.data;
    for (var role in roles) {
      if (data.containsKey(role)) {
        players[role] = RosterPlayer.data(new Map<String, dynamic>.from(data[role]));
      }
      else
        players[role] = RosterPlayer();
    }
    subs = [];
    if (data.containsKey('subs')) {
      for (var player in data['subs']) {
        subs.add(httpService.getPlayer(player));
      }
    }
  }

  Roster.empty() {
    for (var role in roles) players[role] = RosterPlayer();
    subs = [];
  }

  Future<Map<String, dynamic>> getData() async {
    Map<String, dynamic> values = new Map();
    for (var role in roles) values[role] = await players[role].getData();
    var subsID = [];
    for (var player in subs) {
      subsID.add((await player).id);
    }
    values['subs'] = subsID;
    return values;
  }
}

class RosterPlayer {
  Future<Player> player;
  Timestamp assigned;
  double pointsGained;

  RosterPlayer() {
    clear();
  }

  RosterPlayer.data(Map<String, dynamic> data){
    player = httpService.getPlayer(data['id']);
    assigned = data['assigned'];
    pointsGained =  data['points'].toDouble();
  }

  void clear() {
    player = Future.value(Player.empty());
    assigned = Timestamp.now();
    pointsGained = 0.0;
  }

  Future<Map<String, dynamic>> getData() async {
    return {'id': (await player).id, 'assigned': assigned, 'points': pointsGained};
  }
}
