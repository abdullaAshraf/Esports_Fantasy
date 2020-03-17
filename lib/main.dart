import 'package:esports_fantasy/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => UserData(),
        child: App(),
      ),
    );
