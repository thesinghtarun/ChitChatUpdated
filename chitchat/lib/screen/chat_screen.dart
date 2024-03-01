import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chitchat/helper/my_date_util.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/screen/view_profile_screen.dart';
import 'package:chitchat/widgets/message_card.dart';

import '../api/api.dart';
import '../main.dart';
import '../models/messages.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //For Storing All Messages
  List<Message> _list = [];

  //For handling messages from textField
  final _textController = TextEditingController();

  //For storing value of Showing emoji or Hiding Emoji
  bool _showEmoji = false;

  // To cmake textfield scrollable.. (solves bottom overflow error)
  int _lineCount = 1;

  //To show progress of uploading content
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          //If Emojis are shown and back button is pressed then hide emoji
          //or else close current screen if back button is pressed
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: Apis.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //Show progress if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                          //If some or all data is loaded show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: _list.length,
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);
                                  });
                            } else {
                              return const Center(child: Text("Say Hii!👋🏻"));
                            }
                        }
                      }),
                ),

                //Progress Indicator to show something is uploading
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),

                _chatInput(),

                //To show Emoji...........................................
                if (_showEmoji)
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .35,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          columns: 7,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //to Customize AppBar
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ViewProfileScreen(user: widget.user)),
        );
      },
      child: StreamBuilder(
          stream: Apis.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(
              children: [
                //Back Button
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    )),

                //User Profile Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .03),
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.height * .05,
                    height: MediaQuery.of(context).size.height * .05,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),

                //For Adding Some Space
                const SizedBox(width: 10),

                //UserName and LastSeen
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //UserName
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),

                    //For Adding Some Space
                    const SizedBox(height: 2),

                    //Last Seen
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }

  //bottom Chat Input Field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .01,
          horizontal: MediaQuery.of(context).size.width * .010),
      child: Row(
        children: [
          //Input Field and Buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //Emoji Button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 26,
                      )),

                  //Getting user Input(Text Field)
                  Expanded(
                      child: SingleChildScrollView(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: _lineCount <= 5 ? null : 5,
                      onTap: () {
                        if (_showEmoji) {
                          setState(
                            () => _showEmoji = !_showEmoji,
                          );
                        }
                      },
                      onChanged: (text) {
                        // Calculate the number of lines in the TextField
                        final lineCount = text.split('\n').length;
                        if (lineCount != _lineCount) {
                          setState(() {
                            _lineCount = lineCount;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: "Type Something....",
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    ),
                  )),

                  //Pick Image Button(Gallery)
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        //Pick multiple Images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        //Uploading and sending images one by one
                        for (var i in images) {
                          log("Image Path:- ${i.path}");
                          setState(() {
                            _isUploading = true;
                          });
                          await Apis.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),

                  //Click Image Button(Camera)
                  // IconButton(
                  //     onPressed: () async {
                  //       final ImagePicker picker = ImagePicker();
                  //       //Pick an Image
                  //       final XFile? image = await picker.pickImage(
                  //           source: ImageSource.camera, imageQuality: 70);
                  //       if (image != null) {
                  //         log("Image Path:- ${image.path}");
                  //         setState(() {
                  //           _isUploading = true;
                  //         });
                  //         await Apis.sendChatImage(
                  //             widget.user, File(image.path));
                  //         setState(() {
                  //           _isUploading = false;
                  //         });
                  //       }
                  //     },
                  //     icon: const Icon(
                  //       Icons.camera_alt,
                  //       color: Colors.blueAccent,
                  //       size: 26,
                  //     )),

                  //Adding Some Space
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .02,
                  )
                ],
              ),
            ),
          ),

          //Send Message Button
          MaterialButton(
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  //on first message add my_user collection to user collection in firebase
                  if (_list.isEmpty) {
                    Apis.sendFirstMessage(
                        widget.user, _textController.text.trim(), Type.text);
                  } else {
                    //simply send message
                    Apis.sendMessage(
                        widget.user, _textController.text.trim(), Type.text);
                  }
                  _textController.text = "";

                  //To make make line of textfield to null
                  setState(() {
                    _lineCount = 1;
                  });
                }
              },
              minWidth: 0,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 10, right: 5),
              shape: const CircleBorder(),
              color: Colors.greenAccent,
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 26,
              ))
        ],
      ),
    );
  }
}
