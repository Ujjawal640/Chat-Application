import 'dart:convert';
import 'dart:io';

import 'package:chatapp/Proveiders/userProvider.dart';
import 'package:chatapp/Screens/chatscreen.dart';
import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class creategroup extends ConsumerStatefulWidget {
    final Function(bool) onGroupCreated;

    creategroup({required this.onGroupCreated});

  @override
  _creategroupstate createState() => _creategroupstate();
}

class _creategroupstate extends ConsumerState<creategroup> {
  final _searchcontroller = TextEditingController();
  final _groupnamecontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  var searchchatss = [];
  var groupusers = [];
  File? selectedFile;
  var pic = '';
  var usererror = "";

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

      final url = Uri.http(
          "http://10.0.2.2:5174/api/user/?search=$enteredMessage");
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



  void _allsearching() async {
   
    try {
      final userProvide = ref.read(userProvider.notifier);
      final token = userProvide.gettoken();
      print(token);

      final url = Uri.parse(
          'http://10.0.2.2:5174/api/user/?search:');
      final response = await http.get(url, headers: {
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



  Future<bool> _creategroup() async {
    final isvalid = _formkey.currentState!.validate();

    if (isvalid == true) {
      if (groupusers.length < 2) {
        setState(() {
          usererror = "Add more users";
        });
        return false;
      }

      await uploadImage(selectedFile);

      if (pic=='') {
        
      final chatname = _groupnamecontroller.text;
      List<String> selectedIds =
          groupusers.map((u) => u['_id'].toString()).toList();
      String jsonString = jsonEncode(selectedIds);

      try {
        final userProvide = ref.read(userProvider.notifier);
        final token = userProvide.gettoken();
        print("token$token");
        print("uploading$pic");

        final url = Uri.parse("http://10.0.2.2:5174/api/chat/group");
        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              "name": chatname,
              "users": jsonString,
              
            }));
        print(response.body);
        return true;
      } catch (e) {}
        
      } else {
        
      final chatname = _groupnamecontroller.text;
      List<String> selectedIds =
          groupusers.map((u) => u['_id'].toString()).toList();
      String jsonString = jsonEncode(selectedIds);

      try {
        final userProvide = ref.read(userProvider.notifier);
        final token = userProvide.gettoken();
        print("token$token");
        print("uploading$pic");

        final url = Uri.http("10.0.2.2:5174", "/api/chat/group");
        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              "name": chatname,
              "users": jsonString,
              "pic": pic,
            }));
        print(response.body);
        return true;
      } catch (e) {}
        
      }

    
    }
    return false;
  }

  Future<void> uploadImage(pickedImage) async {
    if (pickedImage==null) {
      print("pickedd iamge is null $pickedImage");
      return;
    }
    Uint8List imageBytes = await pickedImage.readAsBytes();
    final Uri url =
        Uri.parse("https://api.cloudinary.com/v1_1/dcluxqd3y/image/upload");

    // Create FormData manually
    final Map<String, String> headers = {
      "Content-Type": "multipart/form-data",
    };

    final http.MultipartRequest request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    // Append fields to FormData
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'uploaded_file.jpg',
    ));

    request.fields['upload_preset'] = 'chat-app';
    request.fields['cloud_name'] = 'dcluxqd3y';

    try {
      final http.Response response =
          await http.Response.fromStream(await request.send());

      // Handle the response
      print('Response: ${(json.decode(response.body))["url"]}');
      setState(() {
        pic = (json.decode(response.body))["url"];
      });
    } catch (error) {
      // Handle errors
      print('Error: $error');
    }
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _allsearching();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Create Group"),
        actions: [
          TextButton(
              onPressed: () async {
                final bool groupcreated = await _creategroup();
                print("groupcreated  $groupcreated");
                if (groupcreated == true) {
                  widget.onGroupCreated(true);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Create Group",
                style: TextStyle(fontSize: 15),
              ))
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: UserImagePicker(onPickImage: (pickedImage) {
                            selectedFile = pickedImage;
                            //uploadImage(pickedImage); ;
                          }),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formkey,
                            child: TextFormField(
                              controller: _groupnamecontroller,
                              decoration: const InputDecoration(
                                hintText: 'Group Name',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 2) {
                                  return "Please enter a valid Group Name";
                                }
                                return null;
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
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
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: groupusers.map((e) {
                        if (e.containsKey('name')) {
                          return InkWell(
                            onTap: () {},
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, left: 16, right: 16),
                                child: Column(
                                  children: [
                                    Row(
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
                                    Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                groupusers.remove(e);
                                              });
                                            },
                                            child: Text("Remove"))
                                      ],
                                    )
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
                Container(
                  child: 
                      Text(
                        usererror,
                        style: TextStyle(color: Colors.red[400]),
                        textAlign: TextAlign.center,
                      )
                    
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(top: 20, bottom: 30),
                  height: MediaQuery.of(context).size.height * 0.33,
                  child: SingleChildScrollView(
                    physics: PageScrollPhysics(),
                    child: Column(
                      children: searchchatss.map((e) {
                        if (e.containsKey('name')) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (groupusers.contains(e)) {
                                  usererror="Can Not Add a user Twice";
                                } else {
                                    groupusers.insert(0, e);
                                }
                              
                              });
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: NetworkImage(
                                          e['pic']), // Replace with your image
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
