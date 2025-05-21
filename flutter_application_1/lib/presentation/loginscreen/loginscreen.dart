import 'package:feed/core/common/custom_images.dart';
import 'package:feed/core/common/custom_textfield.dart';
import 'package:feed/presentation/signupscreen/signupscreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool hidepassword = true;

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
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child:
                        Text("Welcome Back", style: Theme.of(context).textTheme.bodyLarge)),
                Image.asset(
                  "assets/images/—Pngtree—hand drawn pink girl social_5322751.png",
                  width: 300,
                  height: 280,
                ),
                SizedBox(height: 2),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: Customtextfile(
                      controller: emailcontroller,
                      hinttext: "Enter your email",
                      validator: validateEmail,
                      obscureText: false,
                      prefixIcon: Icon(Icons.email),
                      textStyle: TextStyle(
                          fontSize: 18, fontFamily: "Texxt", fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: Customtextfile(
                      controller: passwordcontroller,
                      validator: validatePassword,
                      hinttext: "Enter your password",
                      obscureText: hidepassword,
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon:
                            Icon(hidepassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            hidepassword = !hidepassword;
                          });
                        },
                      ),
                      textStyle: TextStyle(
                          fontSize: 18, fontFamily: "Texxt", fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 27.0),
                    child: GestureDetector(
                      child: Text(
                        "Forgot Password?",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        child: Image.asset(AppImages.google(context),
                            width: 50, height: 50)),
                    SizedBox(width: 15),
                    GestureDetector(
                        child: Image.asset(AppImages.github(context),
                            width: 30, height: 30)),
                  ],
                ),
                SizedBox(height: 10),

                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      if(_formkey.currentState!.validate()){
                        ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('validate')),
                                );
                      }

                      else{
                         ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fix the errors in red before submitting.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                      }
                    },
                    child: Text(
                      "Login",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                SizedBox(height:10),

                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Text(
                      "Don't have an Account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
