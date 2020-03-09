import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/roster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api.dart';
import './playerDetails.dart';
import './widgets/splitter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Roster premadeRoster = new Roster.full(
      Player.card("Huni", 310.18, "top", "CLG"),
      Player.card("Tarzan", 344.15, "jungler", "Griffin"),
      Player.card("Chovy", 332.50, "mid", "Griffin"),
      Player.card("Viper", 395.60, "bot", "Griffin"),
      Player.card("Mata", 76.17, "support", "SKT1"), [
    Player.card("Canyon", 351.55, "jungler", "DAMWON Gaming"),
    Player.card("Faker", 314.01, "mid", "SKT1")
  ]);

  Roster roster = Roster();

  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  HttpService httpService = new HttpService();

  void loadRoster() async {
    final data = await _firestore
        .collection("users")
        .where('id', isEqualTo: loggedInUser.uid)
        .getDocuments();
    final DocumentSnapshot rosterRef =
        await data.documents.first.data["roster"].get();
    setState(() {
      roster = Roster.data(rosterRef);
    });
    await roster.updatePoints();
    setState(() {
      roster = roster;
    });
  }

  void updatePoints() async {}

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        loadRoster();
      }
    } catch (e) {
      Navigator.pushNamedAndRemoveUntil(context, "/registration", (r) => false);
      print(e);
    }
  }

  void getUserRoster() async {
    _firestore.collection('users').add({});
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text('Your Roster'),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(FontAwesomeIcons.signOutAlt),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/registration", (r) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FutureRosterCard(player: roster.top),
            FutureRosterCard(player: roster.jungler),
            FutureRosterCard(player: roster.mid),
            FutureRosterCard(player: roster.bot),
            FutureRosterCard(player: roster.support),
            SizedBox(
              height: 20,
            ),
            Splitter(
              text: "Substitutes",
            ),
            for (var player in roster.subs) FutureRosterCard(player: player),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.store),
            title: Text('  Market'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.users),
            title: Text('  Roster'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.trophy),
            title: Text('  Leaderboard'),
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Color(0xFFC8AA6D),
        backgroundColor: Color(0xFF1D1E33),
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/market');
          break;
        case 2:
          Navigator.pushNamed(context, '/leaderboard');
      }
    });
  }
}

class FutureRosterCard extends StatelessWidget {
  FutureRosterCard({@required this.player});

  final Future<Player> player;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Player>(
      future: player,
      builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
        if (snapshot.hasData) {
          return RosterCard(colour: Color(0xFF1D1E33), player: snapshot.data);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class RosterCard extends StatelessWidget {
  RosterCard({@required this.colour, @required this.player});

  final Color colour;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDetails(player: player),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
        padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image(
              image: AssetImage('assets/images/' + player.role + '.png'),
              height: 60,
            ),
            Text(
              player.tag,
              style: TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
            ),
            Text(
              player.points.round().toString(),
              style: TextStyle(fontSize: 40, color: Color(0xFF8E8E9B)),
            )
          ],
        ),
      ),
    );
  }
}


