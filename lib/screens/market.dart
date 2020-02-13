import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Market extends StatefulWidget {
  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  Future<List<Player>> players;
  HttpService httpService = new HttpService();

  @override
  void initState() {
    super.initState();
    players = httpService.getPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text('Market'),
      ),
      body: Center(
        child: FutureBuilder<List<Player>>(
          future: players,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Player player = snapshot.data[index];
                  return MarketCard(player: player);
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xFFC8AA6D))));
          },
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
        currentIndex: 0,
        selectedItemColor: Color(0xFFC8AA6D),
        backgroundColor: Color(0xFF1D1E33),
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 1:
          Navigator.pushNamed(context, '/');
          break;
        case 2:
          Navigator.pushNamed(context, '/leaderboard');
      }
    });
  }
}

class MarketCard extends StatelessWidget {
  MarketCard({@required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //TODO navigate to player details
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Player details for: " + player.tag),
        ));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
        padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
        decoration: BoxDecoration(
          color: Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/' + player.role + '.png'),
                  height: 60,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      player.tag,
                      style: TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
                    ),
                    Text(
                      player.name,
                      style: TextStyle(fontSize: 16, color: Color(0xFF8E8E9B)),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  player.price.toString() + "\$",
                  style: TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
                ),
                Text(
                  player.points.round().toString(),
                  style: TextStyle(fontSize: 16, color: Color(0xFF8E8E9B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
