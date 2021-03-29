import 'package:enkel_chat/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'chat_list_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // The reason I initialize firebase in the splash screen state is so that
  // while firebase is initializing, we can show a splash screen as apposed
  // to showing nothing, and initializing in main.
  // Splash screen could be showed for a specified amount of time, using
  // a FutureDelayed for example.
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ' + snapshot.error.toString()),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // Firebase has initialized, now check auth
            FirebaseAuth.instance.authStateChanges().listen((User user) {
              if (user == null) {
                return Navigator.pushReplacementNamed(
                    context, RegistrationScreen.id);
              } else {
                return Navigator.pushReplacementNamed(
                    context, ChatListScreen.id);
              }
            });
          }

          // While loading, display splash screen
          return Center(
            child: Icon(
              Icons.group_work,
              size: 72.0,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
