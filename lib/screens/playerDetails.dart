import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class PlayerDetails extends StatefulWidget {
  final Player player;

  @override
  _PlayerDetailsState createState() => _PlayerDetailsState();

  const PlayerDetails({Key key, this.player}) : super(key: key);
}

class _PlayerDetailsState extends State<PlayerDetails> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      Navigator.pushNamedAndRemoveUntil(context, "/registration", (r) => false);
      print(e);
    }
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
        title: Text('Player Details'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Color(0xFF1D1E33),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.userAlt,
                    size: 50,
                    color: Color(0xFFFFFFFF),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        capitalize(widget.player.tag),
                        style:
                            TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
                      ),
                      Text(
                        capitalize(widget.player.name),
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              color: Color(0xFF1D1E33),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.trophy,
                    size: 50,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        capitalize(widget.player.team),
                        style:
                            TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
                      ),
                      Text(
                        capitalize(widget.player.tournament),
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              color: Color(0xFF1D1E33),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: <Widget>[
                  Image(
                    image: AssetImage(
                        'assets/images/' + widget.player.role + '.png'),
                    height: 60,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    capitalize(widget.player.role),
                    style: TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFF1D1E33),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.book,
                    size: 50,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        capitalize(widget.player.country),
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                      ),
                      Text(
                        "Age " + capitalize(widget.player.age.toString()),
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                      ),
                    ],
                  )
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
                          size: 40,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.player.points.round().toString(),
                              style: TextStyle(
                                  fontSize: 32, color: Color(0xFFC8AA6D)),
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
                          size: 40,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.player.price.toString(),
                              style: TextStyle(
                                  fontSize: 32, color: Color(0xFFC8AA6D)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Color(0xFFC8AA6D),
                    height: 75,
                    margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                    child: FlatButton(
                      child: Text(
                        "Assign",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Color(0xFFC8AA6D),
                    height: 75,
                    margin: EdgeInsets.fromLTRB(5, 0, 10, 10),
                    child: FlatButton(
                      child: Text(
                        "Buy",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
