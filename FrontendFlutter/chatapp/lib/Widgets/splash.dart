import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class splash extends StatelessWidget{
  const splash({super.key});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Screen"),
      ),
      body: Center(child: const Text("chats")),
    );
  }

}