import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  MainAppBar({Key key, @required this.title})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 10,
      title: Text(title),
      actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(FontAwesomeIcons.signOutAlt),
          onPressed: () async {
            await Provider.of<UserData>(context, listen: false).signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, "/registration", (r) => false);
          },
        ),
      ],
    );
  }
}
