import 'dart:convert';

import 'package:chatapp/Proveiders/userProvider.dart';
import 'package:chatapp/widgets/message_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';

class singleChat extends ConsumerStatefulWidget {
  const singleChat({Key? key, required this.idd, required this.title})
      : super(key: key);

  final String title;
  final String idd;

  @override
  _singleChatState createState() => _singleChatState();
}

class _singleChatState extends ConsumerState<singleChat>
    with WidgetsBindingObserver {
  var messages = [];
  var loading = false;
  var socketconnected = false;
  var typing = false;
  late String id;
  var user;
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
   bool useractive=false;

  void fetchmessage(String id) async {
    try {
      print("fetching");
      setState(() {
        loading = true;
      });

      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      print("singlechat fetching $id");
      final url = Uri.parse("http://10.0.2.2:5174/api/message/$id");
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print("messages: ${response.body}");
      final data = json.decode(response.body);
      setState(() {
        messages = data;
        loading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

    void read(String id) async {
      try {
        final userProvide = ref.read(userProvider.notifier);
        final token = userProvide.gettoken();
        final iduser = userProvide.getid();
        final url = Uri.parse("http://10.0.2.2:5174/api/message/read");
        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              "chatId": id,
              "userId":iduser,
            }));



        
      } catch (e) {
        print('Error: $e');
      }
    
  }

  void sendmessage(String id) async {
    final newmessage = _messageController.text;
    if (!newmessage.isEmpty) {
      try {
        final userProvide = ref.read(userProvider.notifier);
        final token = userProvide.gettoken();
        final iduser = userProvide.getid();
        final url = Uri.parse("http://10.0.2.2:5174/api/message");
        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              "content": newmessage,
              "chatId": id,
              "readBy":iduser,
            }));

        final data = json.decode(response.body);

        socket.emit("new message", data);
        print(data);

        setState(() {
          messages = [...messages, data];
        });

        print(messages);
        _messageController.clear();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    id = widget.idd;
    fetchmessage(id);
    read(id);
    WidgetsBinding.instance.addObserver(this);
     final userProvide = ref.read(userProvider.notifier);
        final iduser = userProvide.getid();
    initSocket(id,iduser);
  }

  void initSocket(id,iduser) {
    socket = IO.io("http://10.0.2.2:5174", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((data) {
      print('Connected to socket.io server');
    });

    final userProvide = ref.read(userProvider.notifier);

    user = userProvide.getUserData();
    print(user);
    socket.emit('setup', user);

    socket.on('connected', (data) {
      print('Socket.io server connected: ');
    });
    
       

   


    socket.on("message recieved", (newMessageRecieved) {
      print(newMessageRecieved);
      if (id != newMessageRecieved["chat"]["_id"]) {
        // if (!notification.includes(newMessageRecieved)) {
        // setNotification([newMessageRecieved, ...notification]);
        // setFetchAgain(!fetchAgain);
        //}
      } else {
        if (id == newMessageRecieved["chat"]["_id"]) {
          setState(() {
            messages = [...messages, newMessageRecieved];
          });
          print(messages);
        }
      }
    });
  }







  @override
  void dispose() {
    // socket.disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.title;

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            Expanded(child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (ctx, index) {

                final chatMessage = messages[index]["content"];
                 final userProvide = ref.read(userProvider.notifier);
                final userid = userProvide.getid();
                
               
                    return MessageBubble.first(
                      userImage: messages[index]["sender"]["pic"], 
                      username:messages[index]["sender"]["name"],
                      message: chatMessage,
                      isMe: userid == messages[index]["sender"]["_id"],
                      
                    );
              
              },
            )),
            Card(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      // width: 30,
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => sendmessage(widget.idd),
                        //onChanged: typingHandler,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFE0E0E0),
                          hintText: 'Enter a message...',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        sendmessage(widget.idd);
                      },
                      icon: Icon(Icons.arrow_right_outlined))
                ],
              ),
            ),
          ],
        ));
  }
}
