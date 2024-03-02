import 'dart:convert';

import 'package:chatapp/Proveiders/userProvider.dart';
import 'package:chatapp/Screens/auth.dart';
import 'package:chatapp/Screens/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
   runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  void settinguserdata ()async{
    try {
        SharedPreferences prefs= await SharedPreferences.getInstance();
        String? user=prefs.getString("user")!;

         if (user != null) {
      final userInfo = jsonDecode(user);
     

       final userProvide = ref.read(userProvider.notifier);
            userProvide.setUserData(
             User(
        id: userInfo['_id'],
        name: userInfo['name'],
        email: userInfo['email'],
        pic: userInfo['pic'],
        token: userInfo['token'],
      ),
            );


    }

    } catch (e) {
      
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settinguserdata();


  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutterchatapp',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 63, 17, 177))

        
      ),
      home: Consumer(
        builder: (context, watch, child) {
          final user = ref.watch(userProvider);

          if (user != null) {
            // User is logged in, show HomeScreen
            return ChatScreen();
          } else {
            // User is not logged in, show AuthScreen
            return Auth();
          }
        },
      )
    );
  }
}
