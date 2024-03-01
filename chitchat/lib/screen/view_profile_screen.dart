import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/helper/my_date_util.dart';
import 'package:chitchat/models/chat_user.dart';
import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Joined On: ',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          Text(
            MyDateUtil.getJoinedDate(
                context: context, time: widget.user.createdAt),
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //For Adding Some Space
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .03,
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * .1),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.height * .2,
                  height: MediaQuery.of(context).size.height * .2,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),

              //For Adding Some Space
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),

              //User Email
              Text(
                widget.user.email,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),

              //For Adding Some Space
              SizedBox(
                height: MediaQuery.of(context).size.height * .02,
              ),

              //User's about
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'About: ',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  Text(
                    widget.user.about,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
