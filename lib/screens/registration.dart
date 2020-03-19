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
                    decoration:
                        InputDecoration.collapsed(hintText: 'Enter your email'),
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
                    decoration: InputDecoration.collapsed(
                        hintText: 'Enter your password'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FlatButton(
                  child: Text(
                    registered ? 'Login' : 'Register',
                    style: TextStyle(fontSize: 28),
                  ),
                  color: Color(0xFFC8AA6D),
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser = registered
                          ? await _auth.signInWithEmailAndPassword(
                              email: email, password: password)
                          : await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        if (!registered) {
                          final roster = await _firestore
                              .collection('rosters')
                              .add(await Roster.empty().getData());
                          await _firestore.collection('users').add({
                            'balance': 10000,
                            'id': newUser.user.uid,
                            'username': 'user',
                            'points': 0,
                            'roster': roster
                          });
                        }
                        Navigator.pushNamed(context, '/');
                      }
                    } catch (e) {
                      print(e);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  },
                  padding: EdgeInsets.fromLTRB(60, 5, 60, 5),
                ),
                FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(
                    registered
                        ? 'First time here, register instead.'
                        : 'Already have an account, login instead.',
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
}
