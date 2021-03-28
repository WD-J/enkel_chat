import 'package:enkel_chat/screens/chat_list_screen.dart';
import 'package:enkel_chat/screens/chat_screen.dart';
import 'package:enkel_chat/screens/registration_screen.dart';
import 'package:enkel_chat/screens/search_screen.dart';
import 'package:enkel_chat/screens/signin_screen.dart';
import 'package:enkel_chat/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        SignIn.id: (context) => SignIn(),
        ChatListScreen.id: (context) => ChatListScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
