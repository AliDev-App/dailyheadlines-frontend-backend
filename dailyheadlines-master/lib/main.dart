// ignore_for_file: unused_import

import 'package:dailyheadlines/domainside/DomainPostNewsScreen.dart';
import 'package:dailyheadlines/domainside/news_delete.dart';
import 'package:dailyheadlines/view/splash_creen.dart';
import 'package:dailyheadlines/view/userscreen.dart';
// import 'package:dailyheadlines/view/splash_creen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
