import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/screen/profile_screen.dart';

import '../api/api.dart';
import '../main.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //For storing all users
  List<ChatUser> _list = [];

  //For storing searches item
  final List<ChatUser> _searchList = [];

  //For storing search status
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Apis.getSelfInfo();

    //For setting user status Active
    Apis.updateActiveStatus(true);

    //For updating user active status resume:-online pause:-Offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //Hiding Keyboard
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        //If search button is back button will close search
        //If search is off back button will close the app
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.home),

            //Title and Search bar
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name,Email..'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      //Search logic
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text("CHIT-CHAT"),
            actions: [
              //Search Button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),

              //More feature
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: Apis.me)));
                  },
                  icon: const Icon(Icons.more_vert_sharp)),
            ],
          ),
          //To Add New Member To Chat...............................
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
              right: 10,
            ),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: const Icon(Icons.message),
            ),
          ),

          body: StreamBuilder(
            stream: Apis.getMyUserId(),

            // //get id of only known user
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //Show progress if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                //If some or all data is loaded show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                      stream: Apis.getAllUsers(
                          snapshot.data?.docs?.map((e) => e.id).toList() ?? []),

                      //to get only those who's id is provided
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //Show progress if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            //return const Text('No Chats found');
                            return const Center(
                              child: CircularProgressIndicator(),
                            );

                          //If some or all data is loaded show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            //log("Data.... $data");
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _list.length,
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                        user: _isSearching
                                            ? _searchList[index]
                                            : _list[index]);
                                  });
                            } else {
                              return const Center(
                                  child: Text("No Connections Found!"));
                            }
                        }
                      });
              }
            },
          ),
        ),
      ),
    );
  }

  //For Adding User
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add_alt_1,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  Text(' Add Friend'),
                ],
              ),

              //Content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.blueAccent,
                  ),
                  hintText: 'Enter Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              //actions
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                ),

                //Add Button
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await Apis.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'Email not found');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
