import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enkel_chat/widgets/image_message_widget.dart';
import 'package:enkel_chat/widgets/messaging_textfield.dart';
import 'package:enkel_chat/widgets/text_message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
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

  Future<void> uploadMessage(String msg) async {
    try {
      await firebaseImageUpload().then((url) async {
        if (url.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatDocId)
              .update(
            {
              'messages': FieldValue.arrayUnion(
                [
                  {
                    'sender': _auth.currentUser.email,
                    'image': url,
                    'dateTime': DateTime.now(),
                  }
                ],
              ),
            },
          );
          setState(() {
            _image = null;
          });
        }
      });

      if (_messageController.text.trim().isEmpty) {
        return;
      } else {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatDocId)
            .update(
          {
            'messages': FieldValue.arrayUnion(
              [
                {
                  'sender': _auth.currentUser.email,
                  'messageText': msg,
                  'dateTime': DateTime.now(),
                }
              ],
            ),
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void sendMessage() {
    uploadMessage(_messageController.text.trim()).whenComplete(() {
      _messageController.clear();
    });
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

  AsyncMemoizer _asyncMemoizer = AsyncMemoizer();
  void scrollToLastMessage() {
    _asyncMemoizer.runOnce(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatDocId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                            isSender:
                                message['sender'] == _auth.currentUser.email
                                    ? true
                                    : false,
                            dateTime: '',
                            image: message['image'],
                          );
                        } else {
                          return TextMessageWidget(
                            isSender:
                                message['sender'] == _auth.currentUser.email
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
              onEditingComplete: sendMessage,
              onSubmittedButton: sendMessage,
              controller: _messageController,
              pickImage: pickImage,
              image: _image,
            ),
          ],
        ),
      ),
    );
  }
}
