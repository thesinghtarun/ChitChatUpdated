import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/api.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
      if (Apis.auth.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      if (Apis.auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome To CHIT-CHAT"),
      ),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * .15,
            width: MediaQuery.of(context).size.width * .50,
            left: MediaQuery.of(context).size.width * .25,
            child: Image.asset("images/chat.png"),
          ),
          Positioned(
              bottom: MediaQuery.of(context).size.height * .07,
              left: MediaQuery.of(context).size.width * .19,
              // width: MediaQuery.of(context).size.width * .9,
              // height: MediaQuery.of(context).size.height *.06,
              child: const Text(
                "made by SINGH TARUN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ],
      ),
    );
  }
}
