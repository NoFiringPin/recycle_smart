import 'package:flutter/material.dart';
import 'nav/nav_bar.dart';

void main() {
  runApp(const RecycleSmartApp());
}

class RecycleSmartApp extends StatelessWidget {
  const RecycleSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recycle Smart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const NavBar(),
      debugShowCheckedModeBanner: false,
    );
  }
}

