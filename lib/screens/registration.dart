import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/roster.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  String email;
  String password;
  String username;
  bool showSpinner = false;
  bool registered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text(registered ? 'Login' : 'Register'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Color(0xFF1D1E33),
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  width: 300,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration.collapsed(hintText: 'Enter your email'),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  color: Color(0xFF1D1E33),
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  width: 300,
                  child: TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: InputDecoration.collapsed(hintText: 'Enter your password'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Builder(builder: (BuildContext context) {
                  return FlatButton(
                    child: Text(
                      registered ? 'Login' : 'Register',
                      style: TextStyle(fontSize: 28),
                    ),
                    color: Color(0xFFC8AA6D),
                    onPressed: () {
                      if (registered)
                        login(context);
                      else
                        register(context);
                    },
                    padding: EdgeInsets.fromLTRB(60, 5, 60, 5),
                  );
                }),
                FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(
                    registered ? 'First time here, register instead.' : 'Already have an account, login instead.',
                    style: TextStyle(color: Color(0xFF8E8E9B), fontSize: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      registered = !registered;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void register(BuildContext context) async {
    setState(() {
      showSpinner = true;
    });
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (newUser != null) {
        final roster = await _firestore.collection('rosters').add(await Roster.empty().getData());
        await _firestore.collection('users').add({'balance': 10000, 'id': newUser.user.uid, 'username': 'user', 'points': 0, 'roster': roster});
        Navigator.pushNamed(context, '/');
      }
    } catch (e) {
      String errorMessage;
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WEAK_PASSWORD":
          errorMessage = "Your password is weak.";
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          errorMessage = "This email is already used in another account";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      final snackBar = SnackBar(content: Text(errorMessage));
      Scaffold.of(context).showSnackBar(snackBar);
    }
    setState(() {
      showSpinner = false;
    });
  }

  void login(BuildContext context) async {
    setState(() {
      showSpinner = true;
    });
    try {
      final newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (newUser != null) Navigator.pushNamed(context, '/');
    } catch (e) {
      String errorMessage;
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      final snackBar = SnackBar(content: Text(errorMessage));
      Scaffold.of(context).showSnackBar(snackBar);
    }
    setState(() {
      showSpinner = false;
    });
  }
}
