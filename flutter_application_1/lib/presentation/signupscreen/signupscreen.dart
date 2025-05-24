import 'dart:convert';

import 'package:feed/core/common/custom_images.dart';
import 'package:feed/core/common/custom_textfield.dart';
import 'package:feed/firebase_auths/google_firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController firstnamecontroller = TextEditingController();
  TextEditingController lastnamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool hidepassword = true;
  bool isloading = false ; 


  Future<void> signupuser() async{
    final url = Uri.parse('http://192.168.1.5:3000/signup');

    try{
      final response = await http.post(
        url,
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'first_name' : firstnamecontroller.text , 
          'last_name' : lastnamecontroller.text ,
          'email' : emailcontroller.text ,
          'password' : passwordcontroller.text
        })
      );
        
      final data = jsonDecode(response.body);
      if(response.statusCode == 200 || response.statusCode==201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Signup successful! Please check your email to verify your account before logging in.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }

    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error, please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final nameRegExp = RegExp(r'^[a-zA-Z]+$'); // only letters allowed
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Only letters are allowed';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              children: [
                // Main content column wrapped in Form
                Form(
                  key: _formkey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's Build your",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          "FEED Profile",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 40),

                        // Social icons row
                        Center(
                          child: GestureDetector(
                            onTap: (){
                              signInWithGoogle(context);
                            },
                            child: Image.asset(
                              AppImages.google(context),
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Firstname and Lastname input row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              child: Customtextfile(
                                controller: firstnamecontroller,
                                obscureText: false,
                                hinttext: "First Name",
                                validator: validateName,
                                prefixIcon: Icon(Icons.person),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Texxt",
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 150,
                              child: Customtextfile(
                                controller: lastnamecontroller,
                                obscureText: false,
                                hinttext: "Last Name",
                                validator: validateName,
                                prefixIcon: Icon(Icons.person_pin_rounded),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Texxt",
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Email and password inputs column
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 300,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Customtextfile(
                                    controller: emailcontroller,
                                    validator: validateEmail,
                                    obscureText: false,
                                    hinttext: "your email",
                                    prefixIcon: Icon(Icons.person_pin_rounded),
                                    textStyle: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Texxt",
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: 300,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Customtextfile(
                                    controller: passwordcontroller,
                                    obscureText: hidepassword,
                                    validator: validatePassword,
                                    hinttext: "your password",
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          hidepassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          hidepassword = !hidepassword;
                                        });
                                      },
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Texxt",
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Create Account text with GestureDetector
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () async {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  isloading = true ;
                                });
                               await signupuser();

                                setState(() {
                                  isloading = false;  
                                });

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fix the errors in red before submitting.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: isloading ? const CircularProgressIndicator() : Text(
                              "Create Account ? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overlay image on top-right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    "assets/images/vecteezy_mobile-phone-with-love-for-social-media_12414995.png",
                    height: 150,
                    width: 150,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
