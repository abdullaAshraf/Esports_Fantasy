import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/registration.dart';
import 'screens/market.dart';
import 'screens/leaderboard.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esports',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/registration': (context) => Registration(),
        '/market': (context) => Market(),
        '/leaderboard': (context) => Leaderboard(),
      },
    );
  }
}

//0xFFC8AA6D
//0xFF5D4721

//0xFF1D1F33
//0xFF090C22

//#8E8E9B
