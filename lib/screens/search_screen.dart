import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enkel_chat/screens/chat_screen.dart';
import 'package:enkel_chat/widgets/default_styled_textfield.dart';
import 'package:enkel_chat/widgets/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const String id = 'search_screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<QueryDocumentSnapshot> getCurrentUserDoc() async {
    QuerySnapshot currentUser = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _auth.currentUser.email)
        .limit(1)
        .get();
    return currentUser.docs.first;
  }

  void openChat(QueryDocumentSnapshot selectedUser) async {
    QuerySnapshot chatDocs =
        await FirebaseFirestore.instance.collection('chats').where(
      'memberEmails',
      arrayContainsAny: [_auth.currentUser.email, selectedUser['email']],
    ).get();

    if (chatDocs.docs.isNotEmpty) {
      // Chats found with selectedUser
      QueryDocumentSnapshot chatDoc = chatDocs.docs.firstWhere((element) {
        List a = element.data()['members'];
        return a.length == 2;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatDocId: chatDoc.id,
            appBarTitle: selectedUser['name'],
          ),
        ),
      );
    } else {
      // No chat with you and the selectedUser found

      QueryDocumentSnapshot currentUser = await getCurrentUserDoc();

      Map currentUserMap = currentUser.data();
      Map selectedUserMap = selectedUser.data();
      currentUserMap.remove('searchArray');
      selectedUserMap.remove('searchArray');

      DocumentReference chatDoc =
          await FirebaseFirestore.instance.collection('chats').add({
        'memberEmails': [
          currentUserMap['email'],
          selectedUserMap['email'],
        ],
        'members': [
          currentUserMap,
          selectedUserMap,
        ],
        'messages': [],
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatDocId: chatDoc.id,
            appBarTitle: selectedUser['name'],
          ),
        ),
      );
    }
  }

  TextEditingController _searchController = TextEditingController();

  FocusNode _searchFocus = FocusNode();

  bool _isSearching() {
    if (_searchFocus.hasFocus && _searchController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _searchFocus.addListener(_isSearching);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15.0,
              ),
              child: DefaultStyledTextField(
                controller: _searchController,
                hintText: 'Search for users...',
                maxLines: 1,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (string) => setState(() {}),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'searchArray',
                      arrayContains: _searchController.text,
                    )
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> users = snapshot.data.docs;
                    users.removeWhere(
                      (user) =>
                          user.data().containsValue(_auth.currentUser.email),
                    );
                    users.join();

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return UserCard(
                          index: index,
                          usersLength: users.length,
                          onCardTap: () => openChat(users[index]),
                          image: users[index]['pfp'],
                          title: users[index]['name'],
                          description: users[index]['email'],
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
          ],
        ),
      ),
    );
  }
}
