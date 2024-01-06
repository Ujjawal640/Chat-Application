import 'dart:convert';
import 'dart:io';

import 'package:chatapp/Proveiders/userProvider.dart';
import 'package:chatapp/Widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';





class Auth extends ConsumerStatefulWidget{
  const Auth({super.key});

  @override
  _Authstate createState()=> _Authstate();
  
}


class _Authstate extends ConsumerState<Auth>{
  final _formkey = GlobalKey<FormState>();

  var _islogin=true;
  var _enteredemail='';
   var _enteredusername='';
  var Password='';
  var Confirmpassword='';
  File? _selectedFile;


  void submit()async{

    final isvalid=_formkey.currentState!.validate(); //validate function trriger krta textformfield ka
   
      _formkey.currentState!.save();  //onsaved function trriger krta hai textformfield ke

    try{
                 SharedPreferences prefs= await SharedPreferences.getInstance();

   if(_islogin){

    final url = Uri.http("10.0.2.2:5174", "/api/user/login");
    final response=await http.post(url,
    headers: {
      'Content-Type':'application/json'
    },
    body: json.encode({
      
      "email":_enteredemail,
      "password":Password,
      
    })
    );
        if (response.statusCode == 200 ||response.statusCode == 201) {
    // Successful response, you can process the data here
             print("Login successful");
             print("Response: ${response.body}");
        } else {
    // Handle errors
             print("Error: ${response.statusCode}");
             print("Response: ${response.body}");
        }


        await prefs.setString("user", response.body);

        String? user=prefs.getString("user")!;

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



    //final usercred= await _firebase.signInWithEmailAndPassword(email: _enteredemail, password: Password);
   // print(usercred);

      }
   else{

    //for signup
    final url = Uri.http("10.0.2.2:5174", "/api/user/");
    final response=await http.post(url,
    headers: {
      'Content-Type':'application/json'
    },
    body: json.encode({
      "name":_enteredusername,
      "email":_enteredemail, 
      "password":Password,
      
    })
    );

           await prefs.setString("user", response.body);
           String? user=prefs.getString("user")!;

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

    //final usercred=await _firebase.createUserWithEmailAndPassword(email: _enteredemail, password: Password);
    //final storageref=FirebaseStorage.instance.ref().child('user_images').child('${usercred.user!.uid}.jpg');
    //await storageref.putFile(_selectedFile!);
    //final imageurl=await storageref.getDownloadURL();

    //await  FirebaseFirestore.instance.collection('users').doc(usercred.user!.uid).set({
    //'username':_enteredusername,
    //'email':_enteredemail,
    //'image_url':imageurl
  //});

    //print(usercred);
    
   }
   }// on FirebaseAuthException 
   catch (error){
     // if(error.code == 'email-already-in-use'){
        // ... not using this method right now

     // }
      //ScaffoldMessenger.of(context).clearSnackBars();
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication')));
      print(error);


    }

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(

        child: SingleChildScrollView(//very imp to ui probelm of keybord and screen
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,//jo children vo ek vertical column ke center mein aa jayenge
            children: [
        
              Container(
                margin: const EdgeInsets.only(   // this is used for giving custom margin on all side
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: 20
                ),
                width: 100,
                child: Image.asset('assets/chat.png'),
              ),
        
        
              Padding(
                padding: EdgeInsets.all(16),
        
                child: Card(
        
                  child: Padding(
                    padding: EdgeInsets.all(16),
        
                    child: Form(
                      key: _formkey,
        
                      child: Column(
                        mainAxisSize: MainAxisSize.min,// ye vala column minimum size ka ho
                        children: [
                          if(!_islogin) UserImagePicker(
                                        onPickImage:(pickedImage){
                                          _selectedFile=pickedImage;
        
                                        }
                          ),
                          if(!_islogin)  TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username'
                            ),
                           enableSuggestions: false,
                            validator: (value)  {
                              if(value==null || value.trim().isEmpty || value.trim().length <4 ){
                                return "Please enter a valid Username";
        
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enteredusername=value!;
                            }
                          ),
        
        
                    
        
        
        
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Adress'
                            ),
                            //keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value)  {
                              if(value==null || value.trim().isEmpty || !value.contains('@')
                              ){
                                return "Please enter a valid Email Address";
        
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enteredemail=value!;
                            }
                          ),
        
        
        
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password'
                            ),
                            obscureText: true,
                            validator: (value)  {
                              if(value==null || value.trim().isEmpty || value.trim().length<7){
                                return "Please enter a Password of length more than 6";
        
                              }
                              return null;
                            },
                            onSaved: (value){
                              Password=value!;
                            },
                          ),
                          if(!_islogin)TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password'
                            ),
                            obscureText: true,
                            validator: (value)  {
                              if(Confirmpassword!=Password){
                                return "Password's don't match";
                                
                              }
                              return null;
                            },
                            onSaved: (value){
                              Confirmpassword=value!;
                            },
                          )
        
                        ]),
        
                    ),
        
        
                  ),
        
                ),
        
              ),
        
        
        
              const SizedBox(height: 12),
        
        
        
              ElevatedButton(
                onPressed: submit,
               child:  Text(_islogin?'Login':'Signup')),
        
        
        
               TextButton(onPressed: (){
                setState(() {
                    _islogin=!_islogin;
                  });
               },
                style: TextButton.styleFrom(
                      foregroundColor: Colors.white,  
                    ),
                child: Text(_islogin?'Create an account': 'I already have an account'))
        
          ]
        
        
          ),
        ),


      ),

    );
  }

}



