import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../models/roster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api.dart';
import './player_details.dart';
import '../widgets/splitter.dart';
import '../widgets/bottom_navigattion.dart';
import '../widgets/app_bar.dart';
import '../models/user_data.dart';

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
      Player.card("Mata", 76.17, "support", "SKT1"),
      [Player.card("Canyon", 351.55, "jungler", "DAMWON Gaming"), Player.card("Faker", 314.01, "mid", "SKT1")]);

  final _auth = FirebaseAuth.instance;
  HttpService httpService = new HttpService();

  void checkUser() async {
    try {
      await _auth.currentUser();
    } catch (e) {
      Navigator.pushNamedAndRemoveUntil(context, "/registration", (r) => false);
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Your Roster",
      ),
      body: Consumer<UserData>(builder: (context, data, child) {
        return FutureBuilder<Roster>(
          future: data.roster,
          builder: (BuildContext context, AsyncSnapshot<Roster> snapshot) {
            return Center(
              child: Column(
                children: <Widget>[
                  FutureRosterCard(player: snapshot.hasData ? snapshot.data.top : null),
                  FutureRosterCard(player: snapshot.hasData ? snapshot.data.jungler : null),
                  FutureRosterCard(player: snapshot.hasData ? snapshot.data.mid : null),
                  FutureRosterCard(player: snapshot.hasData ? snapshot.data.bot : null),
                  FutureRosterCard(player: snapshot.hasData ? snapshot.data.support : null),
                  SizedBox(
                    height: 20,
                  ),
                  Splitter(
                    text: "Substitutes",
                  ),
                  Column(children: (snapshot.hasData ? snapshot.data.subs : []).map((player) => FutureRosterCard(player: player)).toList())
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavigation(
        currIndex: 1,
      ),
    );
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
          if (snapshot.data.tag == "") {
            return FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                height: 60,
                margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                decoration: BoxDecoration(
                  color: Color(0xFF1D1E25),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    "Empty",
                    style: TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            );
          } else {
            return RosterCard(colour: Color(0xFF1D1E33), player: snapshot.data);
          }
        } else {
          return FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              height: 60,
              margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              decoration: BoxDecoration(
                color: Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF1D1E33),
                valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFC8AA6D)),
              ),
            ),
          );
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
