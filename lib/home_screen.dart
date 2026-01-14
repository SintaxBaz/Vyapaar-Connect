import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Signed in successfully",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
