import 'package:esports_fantasy/models/user.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth = FirebaseAuth.instance;
  HttpService httpService = new HttpService();
  String username;

  void checkUser() async {
    try {
      var user = await _auth.currentUser();
      if (user == null) Navigator.pushNamedAndRemoveUntil(context, "/registration", (r) => false);
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
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FutureBuilder<User>(
                        future: data.user,
                        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                          return Column(
                            children: <Widget>[
                              Container(
                                color: Color(0xFF1D1E33),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.userAlt,
                                      size: 35,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Text(
                                        (snapshot.hasData ? snapshot.data.username : "Username"),
                                        style: TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final snackBar = SnackBar(
                                          duration: const Duration(minutes: 5),
                                          content: TextField(
                                            textAlign: TextAlign.center,
                                            onChanged: (value) {
                                              username = value;
                                            },
                                          ),
                                          action: SnackBarAction(
                                            label: 'Save',
                                            onPressed: () {
                                              data.editUsername(username);
                                            },
                                          ),
                                        );
                                        Scaffold.of(context).showSnackBar(snackBar);
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.solidEdit,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      color: Color(0xFF1D1E33),
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.solidCheckCircle,
                                            size: 35,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                (snapshot.hasData ? snapshot.data.points.round().toString() : "Points"),
                                                style: TextStyle(fontSize: 28, color: Color(0xFFC8AA6D)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Color(0xFF1D1E33),
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.fromLTRB(5, 0, 10, 10),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.dollarSign,
                                            size: 35,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                (snapshot.hasData ? snapshot.data.balance.toString() : "Balance"),
                                                style: TextStyle(fontSize: 28, color: Color(0xFFC8AA6D)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                    Splitter(
                      text: "Main Roster",
                    ),
                    FutureRosterCard(player: snapshot.hasData ? snapshot.data.players['top'].player : null, isSub: false),
                    FutureRosterCard(player: snapshot.hasData ? snapshot.data.players['jungler'].player : null, isSub: false),
                    FutureRosterCard(player: snapshot.hasData ? snapshot.data.players['mid'].player : null, isSub: false),
                    FutureRosterCard(player: snapshot.hasData ? snapshot.data.players['bot'].player : null, isSub: false),
                    FutureRosterCard(player: snapshot.hasData ? snapshot.data.players['support'].player : null, isSub: false),
                    SizedBox(
                      height: 20,
                    ),
                    Splitter(
                      text: "Substitutes",
                    ),
                    Column(
                        children:
                            (snapshot.hasData ? snapshot.data.subs : []).map((player) => FutureRosterCard(player: player, isSub: true)).toList())
                  ],
                ),
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
  FutureRosterCard({@required this.player, @required this.isSub});

  final Future<Player> player;
  final bool isSub;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Player>(
      future: player,
      builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.id == "none") {
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
            return RosterCard(
              colour: Color(0xFF1D1E33),
              player: snapshot.data,
              isSub: isSub,
            );
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
  RosterCard({@required this.colour, @required this.player, @required this.isSub});

  final Color colour;
  final Player player;
  final bool isSub;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Provider.of<UserData>(context, listen: false).updatePlayerPrice(player);
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
            isSub
                ? Container()
                : player.attachment == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFC8AA6D)),
                        ),
                      )
                    : Text(
                        player.attachment.ptsPerGame.toStringAsFixed(1),
                        style: TextStyle(fontSize: 40, color: Color(0xFF8E8E9B)),
                      )
          ],
        ),
      ),
    );
  }
}
