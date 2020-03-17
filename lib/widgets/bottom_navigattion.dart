import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigation extends StatefulWidget {
  int currIndex;

  @override
  _BottomNavigationState createState() => _BottomNavigationState();

  BottomNavigation({@required this.currIndex});
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      currentIndex: widget.currIndex,
      selectedItemColor: Color(0xFFC8AA6D),
      backgroundColor: Color(0xFF1D1E33),
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    if (index == widget.currIndex) return;
    setState(() {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/market');
          break;
        case 1:
          Navigator.pushNamed(context, '/');
          break;
        case 2:
          Navigator.pushNamed(context, '/leaderboard');
      }
    });
  }
}
