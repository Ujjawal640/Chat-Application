import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chatapp/Proveiders/userProvider.dart';
import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Auth extends ConsumerStatefulWidget {
  const Auth({super.key});

  @override
  _Authstate createState() => _Authstate();
}

class _Authstate extends ConsumerState<Auth> {
  final _formkey = GlobalKey<FormState>();

  var _islogin = true;
  var _enteredemail = '';
  var _enteredusername = '';
  var Password = '';
  var Confirmpassword = '';
  var pic = '';

  void submit() async {
    final isvalid = _formkey.currentState!
        .validate(); //validate function trriger krta textformfield ka
    _formkey.currentState!
          .save(); 
    if (isvalid == true) {
      //onsaved function trriger krta hai textformfield ke

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (_islogin) {
          // Create headers with the desired content type
          Map<String, String> headers = {
            'Content-Type': 'application/json',
          };

// Create a map representing the request body
          Map<String, dynamic> requestBody = {
            'email': _enteredemail,
            'password': Password,
          };

// Convert the request body to JSON
          String requestBodyJson = json.encode(requestBody);

// Make the POST request using http package
          http.Response response = await http.post(
            Uri.parse('http://10.0.2.2:5174/api/user/login'),
            headers: headers,
            body: requestBodyJson,
          );

          print(response.body);

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Successful response, you can process the data here
            print("Login successful");
            print("Response: ${response.body}");

            await prefs.setString("user", response.body);

            String? user = prefs.getString("user")!;
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
          } else {
            // Handle errors
            print("Error: ${response.statusCode}");
            print("Response: ${response.body}");

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid email or password")));
          }

          //final usercred= await _firebase.signInWithEmailAndPassword(email: _enteredemail, password: Password);
          // print(usercred);

        } else {
          //for signup
          if (pic == '') {
// Create headers with the desired content type
            Map<String, String> headers = {
              'Content-Type': 'application/json',
            };

// Create a map representing the request body
            Map<String, dynamic> requestBody = {
              'name': _enteredusername,
              'email': _enteredemail,
              'password': Password,
            };

// Convert the request body to JSON
            String requestBodyJson = json.encode(requestBody);

// Make the POST request using http package
            http.Response response = await http.post(
              Uri.parse('http://10.0.2.2:5174/api/user/'),
              headers: headers,
              body: requestBodyJson,
            );

// Check the status code of the response
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Request successful, handle response data
              Map<String, dynamic> responseData = json.decode(response.body);
              // Handle responseData as needed
              print(response.body);
              await prefs.setString("user", response.body);
              String? user = prefs.getString("user")!;

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
            } else {
              // Request failed, handle error
              print('Request failed with status: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          } else {
            // Create headers with the desired content type
            Map<String, String> headers = {
              'Content-Type': 'application/json',
            };

// Create a map representing the request body
            Map<String, dynamic> requestBody = {
              'name': _enteredusername,
              'email': _enteredemail,
              'password': Password,
              'pic': pic
            };

// Convert the request body to JSON
            String requestBodyJson = json.encode(requestBody);

// Make the POST request using http package
            http.Response response = await http.post(
              Uri.parse('http://10.0.2.2:5174/api/user/'),
              headers: headers,
              body: requestBodyJson,
            );

// Check the status code of the response
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Request successful, handle response data
              Map<String, dynamic> responseData = json.decode(response.body);
              // Handle responseData as needed
              await prefs.setString("user", response.body);
              String? user = prefs.getString("user")!;

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
            } else {
              // Request failed, handle error
              print('Request failed with status: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          }
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> uploadImage(pickedImage) async {
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
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        //very imp to ui probelm of keybord and screen
        child: Column(
            mainAxisAlignment: MainAxisAlignment
                .start, //jo children vo ek vertical column ke center mein aa jayenge
            children: [
              Container(
                margin: const EdgeInsets.only(
                    // this is used for giving custom margin on all side
                    top: 100,
                    right: 20,
                    left: 20,
                    bottom: 20),
                width: 100,
                child: Image.asset('assets/chat.png'),
              ),
              Container(
                margin: const EdgeInsets.only(
                    // this is used for giving custom margin on all side
                    top: 20,
                    bottom: 20),
                child: Text("Chatsphere",
                    style: GoogleFonts.inconsolata(
                      textStyle: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      // textAlign: TextAlign.center,
                    )),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 16),
                    child: Form(
                      key: _formkey,
                      child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // ye vala column minimum size ka ho
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              child: Center(
                                  child: Text(
                                _islogin ? "LOGIN" : "SIGNUP",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                textAlign: TextAlign.center,
                              )),
                            ),
                            if (!_islogin)
                              UserImagePicker(onPickImage: (pickedImage) {
                                uploadImage(pickedImage);
                              }),
                            if (!_islogin)
                              TextFormField(
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      fillColor: Colors.grey[300],
                                      filled: true,
                                      labelText: 'Username'),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        value.trim().length < 4) {
                                      return "Please enter a valid Username";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredusername = value!;
                                  }),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade600),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                    ),
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    labelText: 'Email Adress'),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return "Please enter a valid Email Address";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredemail = value!;
                                }),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade600),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade500),
                                  ),
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  labelText: 'Password'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 7) {
                                  return "Please enter a Password of length more than 6";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                Password = value!;
                              },
                            ),
                            if (!_islogin)
                              SizedBox(
                                height: 20,
                              ),
                            if (!_islogin)
                              TextFormField(
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade600),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                    ),
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (Confirmpassword != Password) {
                                    return "Password's don't match";
                                  }
                                  //return ;
                                },
                                onSaved: (value) {
                                  Confirmpassword = value!;
                                },
                              ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                                onPressed: submit,
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll<
                                            Color>(
                                        Theme.of(context).colorScheme.primary)),
                                child: Text(
                                  _islogin ? 'Login' : 'Signup',
                                  style: TextStyle(color: Colors.white),
                                )),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _islogin = !_islogin;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(_islogin
                                    ? 'Create an account'
                                    : 'I already have an account'))
                          ]),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
