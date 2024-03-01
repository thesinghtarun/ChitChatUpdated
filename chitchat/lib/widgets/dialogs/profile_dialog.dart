import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/screen/view_profile_screen.dart';

import '../../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .35,
        child: Stack(
          children: [
            //User Profile Picture
            Positioned(
              top: MediaQuery.of(context).size.height * .075,
              left: MediaQuery.of(context).size.width * .15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * .25),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ),

            //User Name
            Positioned(
              left: MediaQuery.of(context).size.width * .04,
              top: MediaQuery.of(context).size.height * .02,
              width: MediaQuery.of(context).size.width * .55,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Positioned(
                right: 8,
                top: 4,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                  minWidth: 0,
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
