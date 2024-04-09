import 'dart:convert';

import 'package:chatapp/Screens/creategroup.dart';
import 'package:chatapp/Screens/singleChat.dart';
import 'package:chatapp/globalconstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';

import '../Proveiders/userProvider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _searchcontroller = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var chatss = [];
  var searchchatss = [];
  var pic;
  var iduser;
    late IO.Socket socket;


  void logout() async {
    final userProvide = ref.read(userProvider.notifier);
    userProvide.state = null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('user');
  }

   acceschat(String id) async {
    try {
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      final urll = Uri.parse("$url/api/chat");
      final response = await http.post(urll,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"userId": id}));

      setState(() {
        chatss.insert(0, json.decode(response.body));
      });
      var res=json.decode(response.body);
      return res;
    } catch (e) {}
  }


  void _allsearching() async {
   
    try {
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      print(token);

      final urll = Uri.parse(
          '$url/api/user/?search:');
      final response = await http.get(urll, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print("all");
      print(response.body);
      setState(() {
        searchchatss = json.decode(response.body);
      });
      print(searchchatss);
    } catch (e) {}
  }


  void _searching() async {
    final enteredMessage = _searchcontroller.text;
    print(enteredMessage);
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    try {
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      print(token);
      final encodedSearchParameter = Uri.encodeQueryComponent(enteredMessage);

      final urll = Uri.parse(
          '$url/api/user/?search=$enteredMessage');
      final response = await http.get(urll, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print(response.body);
      setState(() {
        searchchatss = json.decode(response.body);
      });
      print(searchchatss);
    } catch (e) {}
  }

  void chats() async {
    try {
      print("chats method in chascreen");
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      print(token);
      http.Response response = await http.get(Uri.parse("$url/api/chat"),headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      //final response = await http.get(url, headers: {
      //  'Content-Type': 'application/json',
      //  'Authorization': 'Bearer $token',
      //});
      print(response.body);
      setState(() {
        chatss = json.decode(response.body);
      });
      print(chatss);
    } catch (e) {
      print(e);
    }
  }

  String getsender(users) {
    final userProvide = ref.read(userProvider.notifier);
    final _id = userProvide.getid();

    var filteredUsers = users.where((user) => user['_id'] != _id);

    if (filteredUsers.isNotEmpty) {
      var firstUser = filteredUsers.first;
      return firstUser['name'].toString();
    } else {
      print('No matching user found.');
    }
    return "";
  }

  String getsenderpic(users) {
    final userProvide = ref.read(userProvider.notifier);
    final _id = userProvide.getid();

    var filteredUsers = users.where((user) => user['_id'] != _id);

    if (filteredUsers.isNotEmpty) {
      var firstUser = filteredUsers.first;
      return firstUser['pic'].toString();
    } else {
      print('No matching user found.');
    }
    return "";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final userProvide = ref.read(userProvider.notifier);
    pic = userProvide.getpic();
    iduser=userProvide.getid();
    chats();
    _allsearching();
    initSocket();
  }

    void initSocket() {
    socket = IO.io("$url", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((data) {
      print('Connected to socket.io server');
    });

    final userProvide = ref.read(userProvider.notifier);

    final user = userProvide.getUserData();
    print(user);
    socket.emit('setup', user);

    socket.on('connected', (data) {
      print('Socket.io server connected: ');
    });

    socket.on("message recieved", (newMessageRecieved) {
      print(newMessageRecieved);
      setState(() {
        chats();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('ChatSphere',
              style: GoogleFonts.inconsolata(
                textStyle:
                    TextStyle(fontWeight: FontWeight.w700, color: const Color.fromARGB(255, 50, 10, 140)
),
              )),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.add_comment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                }),
            InkWell(
              onTap: () {
                print('Avatar tapped');
              },
              child: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(pic),
              ),
            ),
            PopupMenuButton(
                onSelected: (String result) {
                  print("Selected: $result");
                  if (result == "Logout") {
                    logout();
                  } else if (result == "Create Group Chat") {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: ((context) => creategroup(
                              onGroupCreated: (bool groupCreated) {
                                if (groupCreated) {
                                  // Call the chats() method in ChatScreen after group creation
                                  setState(() {
                                    chats();
                                  });
                                }
                              },
                            ))));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.exit_to_app,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Create Group Chat',
                        child: Row(
                          children: [
                            Icon(Icons.group_add_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8),
                            Text('Create Group Chat'),
                          ],
                        ),
                      ),
                    
                    ]),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchcontroller,
                            decoration: const InputDecoration(
                              hintText: 'Enter Name or Email',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _searching();
                          },
                          child: Text('Search'),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      physics: PageScrollPhysics(),
                      child: Column(
                        children: searchchatss.map((e) {
                          if (e.containsKey('name')) {
                            return InkWell(
                              onTap: () async{
                                var res=await acceschat(e['_id']);
                                searchchatss=[];
                                // Navigator.of(context).pop();
                                //change selectedchat id
                                // final schat=ref.read(schatProvider.notifier);
                                print("chatscreen ${e}");
                                // schat.setschatid(e['_id']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: ((context) => singleChat(
                                          title: e['name'],
                                          idd: res['_id'],
                                        ))));

                                        _allsearching();
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20.0,
                                        backgroundImage: NetworkImage(e[
                                            'pic']), // Replace with your image
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(e['name'])
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
       

        body:SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: chatss.length,
                  itemBuilder: (ctx, index) {
                    String name;
                    String senderpic;
                    if (chatss[index]['isGroupChat'] == false) {
                      name = getsender(chatss[index]['users']);
                      senderpic = getsenderpic(chatss[index]['users']);
                    } else {
                      name = chatss[index]['chatName'];
                      senderpic = chatss[index]['pic'];
                    }
                    bool read=true;
                    if (chatss[index]["latestMessage"]!=null) {
                       List<dynamic> readby =
                        chatss[index]["latestMessage"]["readBy"];
                        if (!readby.contains(iduser)) {
                          read = false;
                        }                     
                    } 
                   

                    return InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) => singleChat(
                                  title: name,
                                  idd: chatss[index]['_id'],
                                ))));

                        setState(() {
                          chats();
                        });
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: NetworkImage(senderpic)),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(child: Text(name)),
                              
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        )
        );
  }
}
