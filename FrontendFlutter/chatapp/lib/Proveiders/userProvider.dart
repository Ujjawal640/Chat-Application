import 'package:flutter_riverpod/flutter_riverpod.dart';


class User {
  final String id;
  final String name;
  final String email;
  final String pic;
  final String token;

  User({
    required  this.id,
    required this.name,
    required this.email,
    required this.pic,
    required this.token,
  })//: this._id=id;
 ;
 
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'pic': pic,
      'token': token,
    };
  }
}

class usernotifier extends StateNotifier<User?>{
  usernotifier() : super(null);

  

  void setUserData( User userData) {
    state = userData;
  
}
User? getUserData( ) {
    return state ;
  
}

String? gettoken(){
  return state?.token;
}
String? getid(){
  return state?.id;
}
  
String? getpic(){
  return state?.pic;
}

}

final userProvider = StateNotifierProvider<usernotifier,User?>((ref) {

  return usernotifier();
});

