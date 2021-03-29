import 'package:enkel_chat/blocs/sign_in/sign_in_bloc.dart';
import 'package:enkel_chat/blocs/sign_in/sign_in_bloc_state.dart';
import 'package:enkel_chat/widgets/default_styled_textfield.dart';
import 'package:enkel_chat/widgets/expanded_alone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignIn extends StatefulWidget {
  static const String id = 'signin_screen';

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
    return BlocProvider(
      create: (context) => SignInBloc(context),
      child: Builder(builder: (context) {
        return BlocBuilder<SignInBloc, SignInBlocState>(
          builder: (context, state) {
            final bloc = context.read<SignInBloc>();

            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is SignInBlocLoadingState) ...[
                    const SizedBox(height: 32),
                    LinearProgressIndicator(),
                    const SizedBox(height: 32),
                  ],
                  Text(
                    'Sign in',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                  const SizedBox(height: 50.0),
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
                  const SizedBox(height: 25.0),
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
                  const SizedBox(height: 25.0),
                  if (state is SignInBlocErrorState)
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red[900],
                      ),
                    ),
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: state is! SignInBlocLoadingState
                            ? bloc.register
                            : null,
                        color: Colors.white,
                        textColor: Colors.black87,
                        padding: EdgeInsets.all(15.0),
                        child: Text('   REGISTER   '),
                      ),
                      SizedBox(
                        width: 50.0,
                      ),
                      MaterialButton(
                        onPressed: state is! SignInBlocLoadingState
                            ? () => bloc.signIn(
                                  _emailController.text,
                                  _passwordController.text,
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
          },
        );
      }),
    );
  }
}
