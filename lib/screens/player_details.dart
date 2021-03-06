import 'package:esports_fantasy/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import '../services/api.dart';
import 'package:intl/intl.dart';

const int MaxSubs = 2;

class PlayerDetails extends StatefulWidget {
  final Player player;

  @override
  _PlayerDetailsState createState() => _PlayerDetailsState();

  const PlayerDetails({Key key, this.player}) : super(key: key);
}

class _PlayerDetailsState extends State<PlayerDetails> {
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
        title: "Player Details",
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
                        style: TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
                      ),
                      Text(
                        capitalize(widget.player.name),
                        style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
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
                        style: TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
                      ),
                      Text(
                        capitalize(widget.player.tournament),
                        style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
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
                    image: AssetImage('assets/images/' + widget.player.role + '.png'),
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
                        style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                      ),
                      Text(
                        "Age " + capitalize(widget.player.age.toString()),
                        style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
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
                              style: TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
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
                              style: TextStyle(fontSize: 32, color: Color(0xFFC8AA6D)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            widget.player.attachment == null
                ? Container()
                : Container(
                    color: Color(0xFF1D1E33),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.info,
                          size: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Assigned Since: " + new DateFormat('yyyy-MM-dd HH:MM').format(widget.player.attachment.assigned.toDate().toUtc()),
                                style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF))),
                            Text("Games Played: " + widget.player.attachment.games.toString(),
                                style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF))),
                            Text("Points Gained: " + widget.player.attachment.points.toStringAsFixed(1),
                                style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF))),
                          ],
                        ),
                      ],
                    ),
                  ),
            Expanded(
              child: Container(),
            ),
            Consumer<UserData>(builder: (context, data, child) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Color(0xFFC8AA6D),
                      height: 70,
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                      child: FutureBuilder<bool>(
                        future: data.playerAssigned(widget.player.id),
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          return FlatButton(
                            child: Text(
                              snapshot.hasData ? snapshot.data ? "Unassign" : "Assign" : "Loading",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () async {
                              if (!snapshot.hasData) return;
                              if (snapshot.data)
                                unassign(data, context);
                              else
                                assign(data, context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Color(0xFFC8AA6D),
                      height: 70,
                      margin: EdgeInsets.fromLTRB(5, 0, 10, 10),
                      child: FutureBuilder<bool>(
                        future: data.playerOwned(widget.player.id),
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          return FlatButton(
                            child: Text(
                              snapshot.hasData ? snapshot.data ? "Sell" : "Buy" : "Loading",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {
                              if (!snapshot.hasData) return;
                              if (snapshot.data) {
                                sell(data, context);
                              } else {
                                buy(data, context);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void unassign(UserData data, BuildContext context) async {
    Timestamp assignedSince = await data.playerAssignedSince(widget.player.id);
    if (await httpService.unassignable(widget.player.tournament, widget.player.team, assignedSince)) {
      if ((await data.roster).subs.length >= MaxSubs) {
        final snackBar = SnackBar(
          content: Text('Substitutes at max capacity'),
          action: SnackBarAction(
            label: 'Sell instead',
            onPressed: () {
              data.sellPlayer(widget.player);
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        return;
      } else {
        data.unassignPlayer(widget.player.role, widget.player.id);
      }
    } else {
      final snackBar = SnackBar(content: Text('This player can\'t be unassinged yet'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void assign(UserData data, BuildContext context) async {
    String role = widget.player.role;
    Player assignedPlayer = await (await data.roster).players[role].player;

    if (assignedPlayer.id == "none" ||
        (await httpService.unassignable(assignedPlayer.tournament, assignedPlayer.team, await data.playerAssignedSince(assignedPlayer.id)))) {
      if (await data.playerOwned(widget.player.id)) {
        final snackBar = SnackBar(
          content: Text('Are you sure you want to assign this player?'),
          action: SnackBarAction(
            label: 'Assign',
            onPressed: () {
              data.assignPlayer(widget.player, assignedPlayer.id);
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        if (assignedPlayer.id != "none") {
          final snackBar = SnackBar(content: Text('Bench or sell the player in this role first to free a spot'));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            content: Text('You don\'t have this player'),
            action: SnackBarAction(
              label: 'Buy & Assign',
              onPressed: () async {
                if (!(await data.buyPlayer(widget.player, false))) {
                  final snackBar = SnackBar(content: Text('Your balance is\'t enough to afford this player'));
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              },
            ),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      }
    } else {
      final snackBar = SnackBar(content: Text('Another player locked in this role, and can\'t be unassinged yet'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void buy(UserData data, BuildContext context) async {
    if ((await data.roster).subs.length >= MaxSubs) {
      final snackBar = SnackBar(
        content: Text('Substitutes at max capacity'),
        action: SnackBarAction(
          label: 'Assign instead',
          onPressed: () {
            assign(data, context);
          },
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      if (!(await data.buyPlayer(widget.player, true))) {
        final snackBar = SnackBar(content: Text('Your balance is\'t enough to afford this player'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    }
  }

  void sell(UserData data, BuildContext context) async {
    if (!(await data.playerAssigned(widget.player.id)) ||
        (await httpService.unassignable(widget.player.tournament, widget.player.team, await data.playerAssignedSince(widget.player.id)))) {
      data.sellPlayer(widget.player);
    } else {
      final snackBar = SnackBar(content: Text('This player can\'t be unassinged yet'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
