import 'package:flutter_riverpod/flutter_riverpod.dart';


class Chat {
  String id;
 

  Chat({
    required this.id,
    
  });
}

class schatnotifier extends StateNotifier<Chat?>{
  schatnotifier() : super(Chat(id: ""));

  void setschatid( String chatid) {
    state?.id = chatid;
    print("setting $chatid");
  
}


String? getid(){
      print("getting ${state?.id}");

  return state?.id;
}
  
}

final schatProvider = StateNotifierProvider<schatnotifier,Chat?>((ref) {

  return schatnotifier();
});

