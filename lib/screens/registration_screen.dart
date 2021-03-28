import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enkel_chat/screens/chat_list_screen.dart';
import 'package:enkel_chat/screens/signin_screen.dart';
import 'package:enkel_chat/widgets/default_styled_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  Future<void> registrationMethod() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      DocumentReference userDocument =
          await FirebaseFirestore.instance.collection('users').add({
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'searchArray': setSearchArrayList(_emailController.text.trim()) +
            setSearchArrayList(
              _nameController.text.trim().toLowerCase(),
            )
      });

      await firebaseImageUpload().then((url) {
        userDocument.update({
          'pfp': url,
        });
      });

      return Navigator.pushReplacementNamed(context, ChatListScreen.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          errorMessage = 'Please enter a stronger password';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'Email is already in use';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> firebaseImageUpload() async {
    String url = '';

    if (_image == null) {
      return url;
    }

    String fileName = _image.path.split('/').last;

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    firebase_storage.UploadTask uploadTask =
        storage.ref('$fileName').putFile(_image);

    try {
      firebase_storage.TaskSnapshot snapshot = await uploadTask;

      await snapshot.ref.getDownloadURL().then((downloadedUrl) {
        url = downloadedUrl;
      });
    } catch (e) {
      // TODO: Implement error handling
      print(e);
    }
    return url;
  }

  setSearchArrayList(String stringToSearchArray) {
    List<String> searchArrayList = [];
    String searchArray = '';
    for (int i = 0; i < stringToSearchArray.length; i++) {
      searchArray = searchArray + stringToSearchArray[i];
      searchArrayList.add(searchArray);
    }
    return searchArrayList;
  }

  Future<bool> validateEmail() async {
    final bool isValid = EmailValidator.validate(_emailController.text.trim());
    if (isValid == false) {
      setState(() {
        errorMessage = 'Please enter a valid email';
      });
    } else {
      setState(() {
        errorMessage = '';
      });
    }
    return isValid;
  }

  Future<bool> validateName() async {
    final bool isValid = _nameController.text.trim().isNotEmpty ? true : false;
    if (isValid == false) {
      setState(() {
        errorMessage = 'Please enter a valid name';
      });
    } else {
      setState(() {
        errorMessage = '';
      });
    }
    return isValid;
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  String errorMessage = '';

  File _image;
  final picker = ImagePicker();

  Future _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            'Register',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          SizedBox(
            width: 300.0,
            child: Row(
              children: [
                SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(75.0),
                    color: Colors.transparent,
                    child: _image == null
                        ? InkWell(
                            onTap: _pickImage,
                            child: Container(
                              color: Colors.black12,
                              child: Center(
                                child: Text(
                                  'PFP',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : Ink.image(
                            image: FileImage(_image),
                            fit: BoxFit.cover,
                            child: InkWell(
                              onTap: _pickImage,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: DefaultStyledTextField(
                    controller: _nameController,
                    hintText: 'Name',
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          SizedBox(
            width: 300.0,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DefaultStyledTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          SizedBox(
            width: 300.0,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DefaultStyledTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    maxLines: 1,
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          errorMessage.isNotEmpty
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
                  Navigator.pushReplacementNamed(context, SignIn.id);
                },
                color: Colors.white,
                textColor: Colors.black87,
                padding: EdgeInsets.all(15.0),
                child: Text('   SIGN IN   '),
              ),
              SizedBox(
                width: 50.0,
              ),
              MaterialButton(
                onPressed: () async {
                  await validateName() && await validateEmail()
                      ? registrationMethod()
                      : null;
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
