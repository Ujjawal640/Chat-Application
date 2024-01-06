import 'package:flutter_riverpod/flutter_riverpod.dart';


class User {
  final String id;
  final String name;
  final String email;
  final String pic;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.pic,
    required this.token,
  });
}

class usernotifier extends StateNotifier<User?>{
  usernotifier() : super(null);

  void setUserData( User userData) {
    state = userData;
  
}

String? gettoken(){
  return state?.token;
}
  
}

final userProvider = StateNotifierProvider<usernotifier,User?>((ref) {

  return usernotifier();
});

