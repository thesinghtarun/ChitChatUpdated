import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/api/api.dart';
import 'package:chitchat/helper/my_date_util.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/models/messages.dart';
import 'package:chitchat/screen/chat_screen.dart';
import 'package:chitchat/widgets/dialogs/profile_dialog.dart';

import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //Last Message info (if null means no Message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        //For Navigating to ChatScreen
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: Apis.getLastMessages(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              //user profile img
              leading: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .3),
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.height * .055,
                    height: MediaQuery.of(context).size.height * .055,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              //username
              title: Text(widget.user.name),

              //last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
              ),
              //last message time
              trailing: _message == null
                  ? null //Show nothing when no message is Sent
                  : _message!.read.isEmpty && _message!.fromId != Apis.user.uid
                      ? Container(
                          //Show For Unread Message
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      //Message Sent time
                      : Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _message!.sent,
                          ),
                          style: const TextStyle(color: Colors.black26),
                        ),
            );
          },
        ),
      ),
    );
  }
}
