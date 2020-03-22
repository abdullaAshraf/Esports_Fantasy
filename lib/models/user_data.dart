import 'package:esports_fantasy/models/playerAttachment.dart';
import 'package:flutter/foundation.dart';
import './user.dart';
import './roster.dart';
import './player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData extends ChangeNotifier {
  FirebaseUser _loggedInUser;
  User _user;
  Roster _roster;
  int _maxOwned;
  double _maxPoints;
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

  static const roles = ['top', 'jungler', 'mid', 'bot', 'support'];

  Future<FirebaseUser> get loggedInUser async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        _loggedInUser = user;
        return _loggedInUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void updateRosterPoints() async {
    var r = await roster;

    try {
      List responses = await Future.wait([
        updatePlayerPoints(r.players['top']),
        updatePlayerPoints(r.players['jungler']),
        updatePlayerPoints(r.players['mid']),
        updatePlayerPoints(r.players['bot']),
        updatePlayerPoints(r.players['support'])
      ]);
      double sum = 0;
      responses.forEach((v) => sum += v);

      if (sum > 0) {
        final userRef =
            (await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments()).documents.first.reference;
        userRef.updateData({'points': (await user).points + sum});

        await (await user).roster.updateData(await r.getData());
        (await user).points += sum;
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<double> updatePlayerPoints(RosterPlayer rosterPlayer) async {
    Player p = await rosterPlayer.player;

    if (p.id == "none") return 0;

    //check for server updates
    double assignedPoints = await httpService.getPlayerPoints(p, rosterPlayer.assigned);
    int gamesCount = await httpService.getTeamMatchCountAPI(p.tournament, p.team, rosterPlayer.assigned);

    p.attachment = PlayerAttachment(rosterPlayer.assigned, assignedPoints, gamesCount);
    rosterPlayer.player = Future.value(p);

    double diff = assignedPoints - rosterPlayer.pointsGained;
    rosterPlayer.pointsGained = assignedPoints;
    return diff;
  }

  Future<bool> updatePlayerPrice(Player player) async {
    if (player.price != 0) return false;
    var data = await _firestore.collection("players").document(player.id).get();
    if (data.exists) {
      player.points = data.data['points'].toDouble() / data.data['games'].toDouble();
      player.price = calculatePlayerPrice(player.points, data.data['owned'], await maxPoints, await maxOwned);
      return true;
    } else {
      player.points = 0;
      player.price = calculatePlayerPrice(player.points, 0, await maxPoints, await maxOwned);
      return false;
    }
  }

  int calculatePlayerPrice(double points, int owned, double maxPoints, int maxOwned) {
    double price = 1000;
    price += (owned / maxOwned) * 1000;
    price += (points / maxPoints) * 1000;
    return price.round();
  }

  Future<int> get maxOwned async {
    if (_maxOwned == null) {
      var data = await _firestore.collection("global").document("lastPlayersUpdate").get();
      _maxOwned = data.data["maxOwned"];
      _maxPoints = data.data["maxPoints"];
    }
    return _maxOwned;
  }

  Future<double> get maxPoints async {
    if (_maxOwned == null) {
      var data = await _firestore.collection("global").document("lastPlayersUpdate").get();
      _maxOwned = data.data["maxOwned"];
      _maxPoints = data.data["maxPoints"];
    }
    return _maxPoints;
  }

  Future<Roster> get roster async {
    if (_roster == null) {
      User u = await user;
      _roster = await Roster.data(await u.roster.get());
      updateRosterPoints();
    }
    return _roster;
  }

  Future<User> get user async {
    if (_user == null) {
      final data = await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments();
      _user = User.fromJson(data.documents.first.data);
    }
    return _user;
  }

  void forceRosterUpdate() {
    _roster = null;
    notifyListeners();
  }

  void forceUserUpdate() {
    _user = null;
    notifyListeners();
  }

  void editUsername(String name) async {
    final userRef = (await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments()).documents.first.reference;
    userRef.updateData({'username': name});
    forceUserUpdate();
  }

  void unassignPlayer(String role, String benchedPlayerId) async {
    List<String> subs = [];
    var r = (await roster);
    for (var sub in r.subs) {
      String id = (await sub).id;
      subs.add(id);
    }
    if (benchedPlayerId != "none") subs.add(benchedPlayerId);

    r.players['role'].clear();
    (await user).roster.updateData({role: await r.players[role].getData(), "subs": subs});
    forceRosterUpdate();
  }

  void assignPlayer(Player player, String benchedPlayerId) async {
    List<String> subs = [];
    var r = (await roster);
    for (var sub in r.subs) {
      String id = (await sub).id;
      if (id != player.id) subs.add(id);
    }
    if (benchedPlayerId != "none") subs.add(benchedPlayerId);

    r.players[player.role].player = Future.value(player);
    r.players[player.role].assigned = Timestamp.now();
    r.players[player.role].pointsGained = 0.0;
    (await user).roster.updateData({player.role: await r.players[player.role].getData(), "subs": subs});
    forceRosterUpdate();
  }

  void sellPlayer(Player player) async {
    player.price = 0;
    await updatePlayerPrice(player);
    final userRef = (await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments()).documents.first.reference;
    userRef.updateData({'balance': (await user).balance + player.price});

    var owned = (await _firestore.collection("players").document(player.id).get()).data['owned'];
    await _firestore.collection("players").document(player.id).updateData({'owned': owned - 1});

    //remove from roster
    if (await playerAssigned(player.id)) {
      unassignPlayer(player.role, "none");
    } else {
      List<String> subs = [];
      for (var sub in (await roster).subs) {
        String id = (await sub).id;
        if (id != player.id) subs.add(id);
      }
      (await user).roster.updateData({"subs": subs});
    }

    forceRosterUpdate();
    forceUserUpdate();
  }

  Future<bool> buyPlayer(Player player, bool isSub) async {
    player.price = 0;
    await updatePlayerPrice(player);

    User u = await user;
    if (u.balance < player.price) return false;

    final userRef = (await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments()).documents.first.reference;
    userRef.updateData({'balance': u.balance - player.price});

    var owned = (await _firestore.collection("players").document(player.id).get()).data['owned'];
    await _firestore.collection("players").document(player.id).updateData({'owned': owned + 1});
    if (owned + 1 > await maxOwned) {
      _firestore.collection("global").document('lastPlayersUpdate').updateData({'maxOwned': owned + 1});
    }

    //add to roster
    if (isSub) {
      List<String> subs = [];
      for (var sub in (await roster).subs) {
        subs.add((await sub).id);
      }
      subs.add(player.id);
      u.roster.updateData({"subs": subs});
    } else {
      assignPlayer(player, "none");
    }

    forceRosterUpdate();
    forceUserUpdate();
    return true;
  }

  Future<Timestamp> playerAssignedSince(String id) async {
    Roster r = await roster;

    for (var role in roles) if (id == (await r.players[role].player).id) return r.players[role].assigned;

    return null;
  }

  Future<bool> playerAssigned(String id) async {
    return await playerAssignedSince(id) != null;
  }

  Future<bool> playerOwned(String id) async {
    Roster r = await roster;
    if (await playerAssigned(id)) return true;
    for (var p in r.subs) {
      if (id == (await p).id) return true;
    }
    return false;
  }

  void signOut() async {
    await _auth.signOut();
    _loggedInUser = null;
    _roster = null;
    _user = null;
    notifyListeners();
  }
}
