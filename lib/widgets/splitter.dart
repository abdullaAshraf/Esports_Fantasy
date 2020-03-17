import 'package:flutter/material.dart';

class Splitter extends StatelessWidget {
  Splitter({@required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Divider(
                height: 2,
                color: Color(0xFF8E8E9B),
              ),
            ],
          ),
        ),
        Text(
          '   ' + text + '   ',
          style: TextStyle(fontSize: 18, color: Color(0xFF8E8E9B)),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Divider(
                height: 2,
                color: Color(0xFF8E8E9B),
              ),
            ],
          ),
        )
      ],
    );
  }
}