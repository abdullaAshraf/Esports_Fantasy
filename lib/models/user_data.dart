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
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

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
    await (await roster).updatePoints();
    notifyListeners();
  }

  Future<Roster> get roster async {
    if (_roster != null)
      return _roster;
    else {
      User u = await user;
      _roster = Roster.data(await u.roster.get());
      updateRosterPoints();
      return _roster;
    }
  }

  void forceRosterUpdate() {
    _roster = null;
    notifyListeners();
  }

  void forceUserUpdate() {
    _user = null;
    notifyListeners();
  }

  void unassignPlayer(String role, String benchedPlayerTag) async {
    List<String> subs = [];
    for (var sub in (await roster).subs) {
      String tag = (await sub).tag;
      subs.add(tag);
    }
    if (benchedPlayerTag != "") subs.add(benchedPlayerTag);

    (await user).roster.updateData({role: "", "subs": subs});
    forceRosterUpdate();
  }

  void assignPlayer(Player player, String benchedPlayerTag) async {
    List<String> subs = [];
    for (var sub in (await roster).subs) {
      String tag = (await sub).tag;
      if (tag != player.tag) subs.add(tag);
    }
    if (benchedPlayerTag != "") subs.add(benchedPlayerTag);

    (await user).roster.updateData({player.role: player.tag, player.role + "Assigned": Timestamp.now(), "subs": subs});
    forceRosterUpdate();
  }

  void sellPlayer(Player player) async {
    await player.updatePrice();
    final userRef = (await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments()).documents.first.reference;
    userRef.updateData({'balance': (await user).balance + player.price});

    //remove from roster
    if (await playerAssigned(player.tag)) {
      unassignPlayer(player.role, "");
    } else {
      List<String> subs = [];
      for (var sub in (await roster).subs) {
        String tag = (await sub).tag;
        if (tag != player.tag) subs.add(tag);
      }
      (await user).roster.updateData({"subs": subs});
    }
    forceRosterUpdate();
    forceUserUpdate();
  }

  Future<bool> buyPlayer(Player player, bool isSub) async {
    await player.updatePrice();

    User u = await user;
    if (u.balance < player.price) return false;

    final userRef = (await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments()).documents.first.reference;
    userRef.updateData({'balance': u.balance - player.price});

    //add to roster
    if (isSub) {
      List<String> subs = [];
      for (var sub in (await roster).subs) {
        subs.add((await sub).tag);
      }
      subs.add(player.tag);
      u.roster.updateData({"subs": subs});
    } else {
      assignPlayer(player, "");
    }

    forceRosterUpdate();
    forceUserUpdate();
    return true;
  }

  Future<User> get user async {
    if (_user != null)
      return _user;
    else {
      final data = await _firestore.collection("users").where('id', isEqualTo: (await loggedInUser).uid).getDocuments();
      _user = User.fromJson(data.documents.first.data);
      return _user;
    }
  }

  Future<Timestamp> playerAssignedSince(String tag) async {
    Roster r = await roster;
    if (tag == (await r.top).tag) return r.topAssigned;
    if (tag == (await r.jungler).tag) return r.junglerAssigned;
    if (tag == (await r.mid).tag) return r.midAssigned;
    if (tag == (await r.bot).tag) return r.botAssigned;
    if (tag == (await r.support).tag) return r.supportAssigned;
    return null;
  }

  Future<bool> playerAssigned(String tag) async {
    return await playerAssignedSince(tag) != null;
  }

  Future<bool> playerOwned(String tag) async {
    Roster r = await roster;
    if (await playerAssigned(tag)) return true;
    for (var p in r.subs) {
      if (tag == (await p).tag) return true;
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
