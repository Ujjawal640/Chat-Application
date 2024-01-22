import 'dart:convert';

import 'package:chatapp/Proveiders/schatprovider.dart';
import 'package:chatapp/Widgets/chatmessage.dart';
import 'package:chatapp/Widgets/singleChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Proveiders/userProvider.dart';
import 'new_message.dart';

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

  void logout() async {
    final userProvide = ref.read(userProvider.notifier);
    userProvide.state = null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('user');
  }

  void acceschat(String id) async {
    try {
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      final url = Uri.http("10.0.2.2:5174", "/api/chat");
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"userId": id}));

      setState(() {
        chatss.insert(0, json.decode(response.body));
      });
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

      final url = Uri.http(
          "10.0.2.2:5174", "/api/user/", {"search": encodedSearchParameter});
      final response = await http.get(url, headers: {
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
      //final pic = userProvide.getpic();
      //print(pic);
      print(token);
      final url = Uri.http("10.0.2.2:5174", "/api/chat");
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
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
    chats();
  }

  @override
  Widget build(BuildContext context) {
    final userProvide = ref.read(userProvider.notifier);
      final pic = userProvide.getpic();
     
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('ChatSphere'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              }),
          InkWell(
            onTap: () {
              print('Avatar tapped');
            },
            child: CircleAvatar(
              
              radius: 20.0,
              backgroundImage: NetworkImage(
                  pic!),
            ),
          ),
          PopupMenuButton(
              onSelected: (String result) {
                print("Selected: $result");
                if (result == "Logout") {
                  logout();
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
                      value: 'item2',
                      child: Row(
                        children: [
                          Icon(Icons.group_add_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 8),
                          Text('Create Group Chat'),
                        ],
                      ),
                    ),
                    //  PopupMenuItem<String>(
                    //    value: 'item3',
                    //    child: Row(
                    //      children: const [
                    //        Icon(Icons.mail),
                    //        SizedBox(width: 8),
                    //        Text('Item 1'),
                    //      ],
                    //    ),
                    //  ),
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
                    child: Column(
                      children: searchchatss.map((e) {
                        if (e.containsKey('name')) {
                          return InkWell(
                            onTap: () {
                              acceschat(e['_id']);
                              // Navigator.of(context).pop();
                              //change selectedchat id
                              // final schat=ref.read(schatProvider.notifier);
                              print("chatscreen ${e['_id']}");
                              // schat.setschatid(e['_id']);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: ((context) => singleChat(
                                        title: e['name'],
                                        idd: e['_id'],
                                      ))));
                            },
                            
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                     CircleAvatar(
                                      radius: 20.0,
                                       backgroundImage:
                                          NetworkImage(e['pic']), // Replace with your image
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
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: SingleChildScrollView(
          child: Column(
            children: chatss.map((e) {
              if (e.containsKey('_id')) {
                String name = "chat";
                String senderpic="";
                //String pici=e['pic'];
      
                if (e['isGroupChat'] == false) {

                  setState(() {
                    name = getsender(e['users']);
                    senderpic=getsenderpic(e['users']);
                    
                  });
                } else {

                  setState(() {
                    name = e['chatName'];
                   
                  });
                }

                return InkWell(
                  onTap: () {
                    // final schat=ref.read(schatProvider.notifier);
                    // schat.setschatid(e['_id']);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: ((context) => singleChat(
                              title: name,
                              idd: e['_id'],
                            ))));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                           CircleAvatar(
                              radius: 20.0,
                               backgroundImage: NetworkImage(senderpic)
                             
                              ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(name)
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
      ),
    );
  }
}
