import 'dart:io';

import 'package:enkel_chat/blocs/registration/registration_bloc.dart';
import 'package:enkel_chat/blocs/registration/registration_bloc_state.dart';
import 'package:enkel_chat/widgets/default_styled_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

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
    return BlocProvider(
      create: (context) => RegistrationBloc(context),
      child: Builder(builder: (context) {
        return BlocBuilder<RegistrationBloc, RegistrationBlocState>(
            builder: (context, state) {
          final bloc = context.read<RegistrationBloc>();

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
                SizedBox(height: 25.0),
                if (state is RegistrationBlocErrorState)
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.red[900],
                    ),
                  ),
                const SizedBox(
                  height: 25.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: state is! RegistrationBlocLoadingState
                          ? bloc.signIn
                          : null,
                      color: Colors.white,
                      textColor: Colors.black87,
                      padding: EdgeInsets.all(15.0),
                      child: Text('   SIGN IN   '),
                    ),
                    SizedBox(
                      width: 50.0,
                    ),
                    MaterialButton(
                      onPressed: state is! RegistrationBlocLoadingState
                          ? () => bloc.register(
                                _emailController.text,
                                _passwordController.text,
                                _image,
                                _nameController.text,
                              )
                          : null,
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
        });
      }),
    );
  }
}
