// ignore_for_file: unused_import, unused_local_variable, avoid_unnecessary_containers

import 'dart:async';

import 'package:dailyheadlines/view/userauth/loginpage.dart';
import 'package:dailyheadlines/view/userscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.sizeOf(context).height * 1;
    final screenwidth = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/splash_pic.jpg',
              fit: BoxFit.cover,
              height: screenheight * .5,
            ),
            SizedBox(height: screenheight * 0.04),
            Text(
              'TOP HEADLINES',
              style: GoogleFonts.anton(
                letterSpacing: 0.6,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: screenheight * 0.04),
            SpinKitChasingDots(color: Colors.blue, size: 40),
          ],
        ),
      ),
    );
  }
}
