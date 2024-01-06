import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Mydrawer extends StatefulWidget{
    


  @override
  State<Mydrawer> createState() {
    // TODO: implement createState
    return _MydrawerState();
  }
}

class _MydrawerState extends State<Mydrawer>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Drawer(
    child: Text("hello"),
   );
  }

}