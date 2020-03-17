import 'package:esports_fantasy/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './player_details.dart';
import '../widgets/bottom_navigattion.dart';

class Market extends StatefulWidget {
  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  Future<List<Player>> players;
  String searchTag = "";
  var searchRoles = {
    'top': true,
    'jungler': true,
    'mid': true,
    'bot': true,
    'support': true
  };
  HttpService httpService = new HttpService();

  @override
  void initState() {
    super.initState();
    players = httpService.getPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Market",
      ),
      body: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              Icon(FontAwesomeIcons.search),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Search by tag'),
                  onChanged: (text) {
                    setState(() {
                      searchTag = text;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RoleFilter(
                active: searchRoles['top'],
                role: 'top',
                onClick: onFilterClick,
              ),
              RoleFilter(
                active: searchRoles['jungler'],
                role: 'jungler',
                onClick: onFilterClick,
              ),
              RoleFilter(
                active: searchRoles['mid'],
                role: 'mid',
                onClick: onFilterClick,
              ),
              RoleFilter(
                active: searchRoles['bot'],
                role: 'bot',
                onClick: onFilterClick,
              ),
              RoleFilter(
                active: searchRoles['support'],
                role: 'support',
                onClick: onFilterClick,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder<List<Player>>(
              future: players,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      Player player = snapshot.data[index];
                      return player.tag.toLowerCase().contains(searchTag.toLowerCase()) &&
                              searchRoles[player.role]
                          ? MarketCard(player: player)
                          : new Container();
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xFFC8AA6D)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currIndex: 0,
      ),
    );
  }

  onFilterClick(String role) {
    setState(() {
      searchRoles[role] = !searchRoles[role];
    });
  }
}

class RoleFilter extends StatelessWidget {
  RoleFilter(
      {@required this.active, @required this.role, @required this.onClick});

  final bool active;
  final String role;
  final Function(String) onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(role),
      child: Image(
        image: AssetImage('assets/images/' + role + '.png'),
        color: active ? null : Colors.grey,
        height: 50,
      ),
    );
  }
}

class MarketCard extends StatelessWidget {
  MarketCard({@required this.player});

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
                Container(
                  width: 260,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        player.tag,
                        style:
                            TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
                      ),
                      Text(
                        player.team,
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF8E8E9B)),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
