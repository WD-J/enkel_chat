import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enkel_chat/screens/search_screen.dart';
import 'package:enkel_chat/widgets/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  static const String id = 'chat_list_screen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  void openChat(Map selectedUser, String chatDocId) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatDocId: chatDocId,
          appBarTitle: selectedUser['name'],
          // TODO: push the selected user to the next screen so that you can just uuh use it
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.pushNamed(context, SearchScreen.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('chats').where(
            'memberEmails',
            arrayContainsAny: [_auth.currentUser.email],
          ).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> chatList = snapshot.data.docs;

              return ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (BuildContext context, int index) {
                  List chatMembersList = chatList[index]['members'];
                  chatMembersList.removeWhere(
                      (user) => user['email'] == _auth.currentUser.email);
                  chatList.join();

                  Map users = chatMembersList[index];
                  List messageList = chatList[index]['messages'];
                  String lastMessage = '';
                  Timestamp dateTime;
                  String dateTimeToString = '';

                  if (messageList.isEmpty) {
                    lastMessage = '';
                  } else {
                    if (messageList.last['image'] != null) {
                      lastMessage = 'Sent an image...';
                    } else {
                      lastMessage = messageList.last['messageText'];
                    }

                    dateTime = messageList.last['dateTime'];

                    dateTimeToString = timeago.format(dateTime.toDate());
                  }

                  return UserCard(
                    index: index,
                    usersLength: chatList.length,
                    onCardTap: () => openChat(users, chatList[index].id),
                    image: users['pfp'],
                    title: users['name'],
                    description: lastMessage,
                    dateTime: dateTimeToString,
                  );
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
    );
  }
}
