import 'dart:core';

import 'package:enkel_chat/blocs/search/search_bloc.dart';
import 'package:enkel_chat/blocs/search/search_bloc_state.dart';
import 'package:enkel_chat/widgets/default_styled_textfield.dart';
import 'package:enkel_chat/widgets/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  static const String id = 'search_screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(context)..initialize(),
      child: Builder(builder: (context) {
        return BlocBuilder<SearchBloc, SearchBlocState>(
            builder: (context, state) {
          final bloc = context.read<SearchBloc>();

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
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: bloc.search,
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state is SearchBlocLoadedState) {
                          final users = state.snapshot.docs;
                          users.removeWhere(
                            (user) => user
                                .data()
                                .containsValue(_auth.currentUser.email),
                          );
                          users.join();

                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (BuildContext context, int index) {
                              return UserCard(
                                index: index,
                                usersLength: users.length,
                                onCardTap: () => bloc.openChat(users[index]),
                                image: users[index]['pfp'],
                                title: users[index]['name'],
                                description: users[index]['email'],
                              );
                            },
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }),
    );
  }
}
