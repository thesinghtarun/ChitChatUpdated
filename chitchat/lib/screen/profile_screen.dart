import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chitchat/models/chat_user.dart';

import '../api/api.dart';
import '../helper/dialogs.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        //For hiding Keyboard
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Profile Screen"),
          ),

          body: Form(
            key: _formKey,
            child: Padding(
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

                    Stack(
                      children: [
                        //Profile Picture
                        _image != null
                            ?

                            //Local image{User Profile image}
                            //If statement--------------------------------------------------------------
                            ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  width:
                                      MediaQuery.of(context).size.height * .2,
                                  height:
                                      MediaQuery.of(context).size.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            //Else Statement------------------------------------------------------------------
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height * .1),
                                child: CachedNetworkImage(
                                  width:
                                      MediaQuery.of(context).size.height * .2,
                                  height:
                                      MediaQuery.of(context).size.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                ),
                              ),

                        //Edit Image Button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            onPressed: () {
                              _showBottomSheet();
                            },
                            elevation: 0,
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                          ),
                        )
                      ],
                    ),

                    //For Adding Some Space
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .03,
                    ),

                    //User Email
                    Text(
                      widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),

                    //For Adding Some Space
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .05,
                    ),

                    //User Name Text Field
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => Apis.me.name = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        hintText: "eg. Ram",
                        label: const Text("Name"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    //For Adding Some Space
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .02,
                    ),

                    //About Input Field
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => Apis.me.about = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        hintText: "eg. Jai Shree Ram",
                        label: const Text("About"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    //For Adding Some Space
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .02,
                    ),

                    //Update Profile Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * .5,
                              MediaQuery.of(context).size.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Apis.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(
                                context, "Updated Successfully");
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 28,
                      ),
                      label: const Text(
                        "UPDATE",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Logout Button
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              label: const Text("Logout"),
              icon: const Icon(Icons.logout),
              onPressed: () async {
                //Adding progress dialog
                Dialogs.showProgress(context);

                await Apis.updateActiveStatus(false);

                //Signout
                await Apis.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //Hiding progress dialog
                    Navigator.pop(context);

                    //Moving to homescreen
                    Navigator.pop(context);

                    Apis.auth = FirebaseAuth.instance;

                    //Replacing homescreen with loginscreen
                    Navigator.pushReplacementNamed(context, '/login');
                  });
                });
              },
            ),
          ),
        ));
  }

  //Bottom sheet for picking profile pic
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .03,
                bottom: MediaQuery.of(context).size.height * .05),
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * .02),
              //Images Camera Image Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Add image from gallery for profile pic
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * .3,
                              MediaQuery.of(context).size.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);

                        if (image != null) {
                          log('Image path:${image.path}---mime type${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });

                          //Calling function to update profile picture
                          Apis.updateProfilePicture(File(_image!));

                          //For hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/gallery.jpg')),

                  //Take image for profile pic
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * .3,
                              MediaQuery.of(context).size.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);

                        if (image != null) {
                          log('Image path:${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          //Calling function to update profile picture
                          Apis.updateProfilePicture(File(_image!));

                          //For hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.jpg')),
                ],
              )
            ],
          );
        });
  }
}
