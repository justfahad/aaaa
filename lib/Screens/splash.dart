import 'package:flutter/material.dart';

class splashScreen extends StatelessWidget{
  const splashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
  title: const Text('Profile'),
  centerTitle: true, // Centers the title
),

      body: const Center(
        child: Text('Loding...'),
      ),
    );
  }
}