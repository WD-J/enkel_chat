import 'package:email_validator/email_validator.dart';
import 'package:enkel_chat/screens/registration_screen.dart';
import 'package:enkel_chat/widgets/default_styled_textfield.dart';
import 'package:enkel_chat/widgets/expanded_alone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_list_screen.dart';

class SignIn extends StatefulWidget {
  static const String id = 'signin_screen';

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  Future<void> signInMethod() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      return Navigator.pushReplacementNamed(context, ChatListScreen.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessageEnabled = true;
          errorMessage = 'No user found for the given email';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorMessageEnabled = true;
          errorMessage = 'Incorrect password';
        });
      }
    }
  }

  Future<bool> validateEmail() async {
    final bool isValid = EmailValidator.validate(_emailController.text);
    if (isValid == false) {
      setState(() {
        errorMessageEnabled = true;
        errorMessage = 'Please enter a valid email';
      });
    } else {
      setState(() {
        errorMessageEnabled = false;
        errorMessage = '';
      });
    }
    return isValid;
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool errorMessageEnabled = false;
  String errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign in',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          Row(
            children: [
              ExpandedAlone(),
              Expanded(
                flex: 5,
                child: DefaultStyledTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  maxLines: 1,
                ),
              ),
              ExpandedAlone(),
            ],
          ),
          SizedBox(
            height: 25.0,
          ),
          Row(
            children: [
              ExpandedAlone(),
              Expanded(
                flex: 5,
                child: DefaultStyledTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  maxLines: 1,
                  obscureText: true,
                ),
              ),
              ExpandedAlone(),
            ],
          ),
          SizedBox(
            height: 25.0,
          ),
          errorMessageEnabled
              ? Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red[900],
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 25.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, RegistrationScreen.id);
                },
                color: Colors.white,
                textColor: Colors.black87,
                padding: EdgeInsets.all(15.0),
                child: Text('   REGISTER   '),
              ),
              SizedBox(
                width: 50.0,
              ),
              MaterialButton(
                onPressed: () async {
                  await validateEmail().then((isValid) {
                    isValid == true ? signInMethod() : null;
                  });
                },
                color: Colors.white,
                textColor: Colors.black87,
                padding: EdgeInsets.all(15.0),
                child: Text('   CONTINUE   '),
              ),
            ],
          )
        ],
      ),
    );
  }
}
