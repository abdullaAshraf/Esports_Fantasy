import 'package:cloud_firestore/cloud_firestore.dart';

import './player.dart';
import '../services/api.dart';

HttpService httpService = HttpService();

class Roster {
  Future<Player> top, jungler, mid, bot, support;
  Timestamp topAssigned,
      junglerAssigned,
      midAssigned,
      botAssigned,
      supportAssigned;

  List<Future<Player>> subs = [];

  Roster();

  Roster.full(Player top, Player jungler, Player mid, Player bot,
      Player support, List<Player> subs)
      : top = Future<Player>.value(top),
        jungler = Future<Player>.value(jungler),
        mid = Future<Player>.value(mid),
        bot = Future<Player>.value(bot),
        support = Future<Player>.value(support) {
    this.subs = [];
    for (var player in subs) {
      this.subs.add(Future<Player>.value(player));
    }
  }

  Roster.data(DocumentSnapshot data)
      : topAssigned = data['topAssigned'],
        botAssigned = data['botAssigned'],
        midAssigned = data['midAssigned'],
        junglerAssigned = data['junglerAssigned'],
        supportAssigned = data['supportAssigned'] {
    top = httpService.getPlayer(data['top']);
    mid = httpService.getPlayer(data['mid']);
    jungler = httpService.getPlayer(data['jungler']);
    bot = httpService.getPlayer(data['bot']);
    support = httpService.getPlayer(data['support']);
    subs = [];
    for (var player in data['subs']) {
      subs.add(httpService.getPlayer(player));
    }
  }
}

final Map<String, dynamic> emptyRoster = {
  'bot': "",
  'botAssigned': Timestamp.now(),
  'jungler': "",
  'junglerAssigned': Timestamp.now(),
  'mid': "",
  'midAssigned': Timestamp.now(),
  'top': "",
  'topAssigned': Timestamp.now(),
  'support': "",
  'supportAssigned': Timestamp.now(),
  'subs': List<String>()
};
