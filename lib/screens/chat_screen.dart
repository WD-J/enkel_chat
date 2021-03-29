import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enkel_chat/blocs/chat/chat_bloc.dart';
import 'package:enkel_chat/blocs/chat/chat_bloc_state.dart';
import 'package:enkel_chat/widgets/image_message_widget.dart';
import 'package:enkel_chat/widgets/messaging_textfield.dart';
import 'package:enkel_chat/widgets/text_message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  ChatScreen({
    Key key,
    this.chatDocId,
    this.appBarTitle,
  }) : super(key: key);

  final String chatDocId;
  final String appBarTitle;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  ScrollController _scrollController = ScrollController();
  TextEditingController _messageController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future pickImage() async {
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
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(widget.chatDocId)..initialize(),
      child: Builder(builder: (context) {
        return BlocListener<ChatBloc, ChatBlocState>(
          listener: (_, state) {
            if (state is ChatBlocMessageSentState) {
              _messageController.clear();
              _image = null;
            }
          },
          child:
              BlocBuilder<ChatBloc, ChatBlocState>(builder: (context2, state) {
            final bloc = context2.read<ChatBloc>();

            if (state is ChatBlocInitialState) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.appBarTitle),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: (state as dynamic).stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List messageList = snapshot.data['messages'];
                            messageList = messageList.reversed.toList();
                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: messageList.length,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 5.0,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                Map message = messageList[index];

                                if (message['image'] != null) {
                                  return ImageMessageWidget(
                                    isSender: message['sender'] ==
                                            _auth.currentUser.email
                                        ? true
                                        : false,
                                    dateTime: '',
                                    image: message['image'],
                                  );
                                } else {
                                  return TextMessageWidget(
                                    isSender: message['sender'] ==
                                            _auth.currentUser.email
                                        ? true
                                        : false,
                                    dateTime: '', //message['dateTime'],
                                    messageText: message['messageText'],
                                  );
                                }
                              },
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ' + snapshot.data.toString(),
                              ),
                            );
                          }

                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black38,
                    ),
                    MessagingTextField(
                      onEditingComplete: () => bloc.sendChat(
                        _messageController.text,
                        _image,
                      ),
                      onSubmittedButton: () => bloc.sendChat(
                        _messageController.text,
                        _image,
                      ),
                      controller: _messageController,
                      pickImage: pickImage,
                      image: _image,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
