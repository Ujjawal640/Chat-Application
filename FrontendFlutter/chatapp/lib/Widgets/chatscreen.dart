import 'package:chatapp/Widgets/Mydrawer.dart';
import 'package:chatapp/Widgets/chatmessage.dart';
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

  void logout() async {
    final userProvide = ref.read(userProvider.notifier);
    userProvide.state = null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('user');
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

    final url = Uri.http("10.0.2.2:5174", "/api/user/", {"search": encodedSearchParameter});
    final response=await http.get(url,
    headers: {
      'Content-Type':'application/json',
      'Authorization': 'Bearer $token',
 
    }
    );
      print(response.body);
     
    } catch (e) {
      
    }

    }

  void chats() async {
    try {
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      print(token);
      final url = Uri.http("10.0.2.2:5174", "/api/chat");
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('ChatSphere'),
        automaticallyImplyLeading:
            false, //  this line hide the default drawer icon
        actions: [
          IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              }),
          InkWell(
            onTap: () {
              // Handle the tap event
              print('Avatar tapped');
            },
            child: CircleAvatar(
              radius: 20.0,
              backgroundImage:
                  AssetImage('assets/chat.png'), // Replace with your image
            ),
          ),
          PopupMenuButton(
              onSelected: (String result) {
                // Handle menu item selection
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
                          Icon(Icons.mail),
                          SizedBox(width: 8),
                          Text('Item 1'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'item3',
                      child: Row(
                        children: [
                          Icon(Icons.mail),
                          SizedBox(width: 8),
                          Text('Item 1'),
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
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchcontroller,
                decoration: InputDecoration(
                  hintText: 'Enter Name or Email',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle button press
                _searching();
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
      // Add more ListTiles or other widgets as needed
    ],
  ),
),

      body: Column(
          //children: const [
          //Expanded(

          //),
          //  New_Message(),
          // ],
          ),
    );
  }
}
