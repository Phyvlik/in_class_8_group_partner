import 'package:flutter/material.dart';
import 'screens/folders_screen.dart';

void main() {
  runApp(CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Organizer',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: FoldersScreen(),
    );
  }
}