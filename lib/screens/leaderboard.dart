import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
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
        title: Text('Leaderboard'),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .orderBy('points', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<UserCard> usersCards = [];
            final users = snapshot.data.documents;
            int rank = 1;
            for (var user in users) {
              final username = user.data['username'];
              final points = user.data['points'];
              Color colour = Color(0xFF1D1E33);
              if(loggedInUser != null && loggedInUser.uid == user.data['id'])
                colour = Color(0xFF5D4721);
              final userCard = UserCard(
                  colour: colour,
                  rank: rank,
                  points: points,
                  username: username);
              usersCards.add(userCard);
              rank++;
            }
            return ListView(
              children: usersCards,
            );
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
        currentIndex: 2,
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
        case 1:
          Navigator.pushNamed(context, '/');
      }
    });
  }
}

class UserCard extends StatelessWidget {
  UserCard(
      {@required this.colour,
      @required this.username,
      @required this.points,
      @required this.rank});

  final Color colour;
  final String username;
  final int points;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            rank.toString(),
            style: TextStyle(fontSize: 32, color: Color(0xFFFFFFFF)),
          ),
          Text(
            username,
            style: TextStyle(fontSize: 28, color: Color(0xFFFFFFFF)),
          ),
          Text(
            points.toString(),
            style: TextStyle(fontSize: 32, color: Color(0xFF8E8E9B)),
          )
        ],
      ),
    );
  }
}
