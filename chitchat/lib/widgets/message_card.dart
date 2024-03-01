import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:chitchat/api/api.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:chitchat/helper/my_date_util.dart';

import '../main.dart';
import '../models/messages.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  //Sender or Another User
  Widget _blueMessage() {
    //Update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Message Content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? MediaQuery.of(context).size.width * .03
                : MediaQuery.of(context).size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                //Making border curve
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //Show Text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //Show Image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  //Our or Current User Message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //For Adding some extra space
            SizedBox(width: MediaQuery.of(context).size.width * .04),
            //Double Tick blue for Message Read
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            //For Adding some extra space
            const SizedBox(width: 2),
            //Sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),

        //Message Content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? MediaQuery.of(context).size.width * .03
                : MediaQuery.of(context).size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                //Making border curve
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //Show Text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //Show Image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //Bottom Sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            //Copy Option
            widget.message.type == Type.text
                ? _OptionItem(
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, 'Copied');
                      });
                    })
                :
                //Save Option
                _OptionItem(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'Chit Chat')
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackbar(context, 'Image Saved');
                          }
                        });
                      } catch (e) {
                        log('Error While Saving Image: $e');
                      }
                    }),

            //Separator line
            if (isMe)
              Divider(
                color: Colors.black54,
                indent: MediaQuery.of(context).size.width * .04,
                endIndent: MediaQuery.of(context).size.width * .04,
              ),

            //Delete Option
            if (isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                  name: 'Delete Text',
                  onTap: () async {
                    await Apis.deleteMessage(widget.message).then((value) {
                      Navigator.pop(context);
                      Dialogs.showSnackbar(context, 'Deleted');
                    });
                  }),

            //Separator line
            Divider(
              color: Colors.black54,
              indent: MediaQuery.of(context).size.width * .04,
              endIndent: MediaQuery.of(context).size.width * .04,
            ),

            //Sent Time
            _OptionItem(
                icon: const Icon(
                  Icons.done,
                  color: Colors.grey,
                ),
                name:
                    'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {}),

            //Read Time
            _OptionItem(
                icon: const Icon(
                  Icons.done_all,
                  color: Colors.blueAccent,
                ),
                name: widget.message.read.isEmpty
                    ? 'Not seen yet'
                    : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {}),
          ]);
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .05,
            top: MediaQuery.of(context).size.height * .025,
            bottom: MediaQuery.of(context).size.height * .02),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '    $name',
              style: const TextStyle(
                  fontSize: 15, color: Colors.black87, letterSpacing: 0.5),
            )),
          ],
        ),
      ),
    );
  }
}
