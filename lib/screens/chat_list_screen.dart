import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enkel_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:enkel_chat/blocs/chat_list/chat_list_bloc_state.dart';
import 'package:enkel_chat/screens/search_screen.dart';
import 'package:enkel_chat/widgets/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  static const String id = 'chat_list_screen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final bloc = ChatListBloc()..initialize();
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
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat List'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () => Navigator.pushNamed(context, SearchScreen.id),
            ),
          ],
        ),
        body: BlocBuilder<ChatListBloc, ChatListBlocState>(
          bloc: bloc,
          builder: (context, state) {
            if (state is ChatListInitialState) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is ChatListInitializedState) {
              return SafeArea(
                child: StreamBuilder<QuerySnapshot>(
                  stream: state.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot> chatList = snapshot.data.docs;

                      if (chatList.length == 0) {
                        return Center(
                          child: Text(
                            'Search for a chat to get started!',
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: chatList.length,
                        itemBuilder: (BuildContext context, int index) {
                          List messageList = chatList[index]['messages'];

                          // This should sort the list based on dateTime
                          chatList.sort((a, b) {
                            List one = b['messages'];
                            List two = a['messages'];

                            if (one.isEmpty) {
                              one.add({
                                'dateTime': Timestamp.fromDate(DateTime.now()),
                              });
                            }

                            if (two.isEmpty) {
                              two.add({
                                'dateTime': Timestamp.fromDate(DateTime.now()),
                              });
                            }

                            return one.last['dateTime']
                                .compareTo(two.last['dateTime']);
                          });

                          // This takes the user first in the members
                          // list. This can be changed to support group chat
                          List chatMembersList = chatList[index]['members'];
                          chatMembersList.removeWhere((user) =>
                              user['email'] == _auth.currentUser.email);
                          chatMembersList.join();
                          Map user = chatMembersList.first;

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
                            dateTimeToString = timeago.format(
                              dateTime.toDate(),
                            );
                          }

                          return UserCard(
                            index: index,
                            usersLength: chatList.length,
                            onCardTap: () => openChat(user, chatList[index].id),
                            image: user['pfp'],
                            title: user['name'],
                            description: lastMessage,
                            dateTime: dateTimeToString,
                          );
                        },
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ' + snapshot.error.toString(),
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
