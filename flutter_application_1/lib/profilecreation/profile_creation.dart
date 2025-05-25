import 'dart:io';

import 'package:feed/core/common/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCreation extends StatefulWidget {
  const ProfileCreation({super.key});

  @override
  State<ProfileCreation> createState() => _ProfileCreationState();
}

class _ProfileCreationState extends State<ProfileCreation> {
  // Move controllers here
  final TextEditingController bio = TextEditingController();
  final TextEditingController username = TextEditingController();

  File? pfpImage; // Store picked image file
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<void> pickPfp() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pfpImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    bio.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                "Profile Creation",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 50),

              // Username
              SizedBox(
                width: 150,
                child: Customtextfile(
                  controller: username,
                  obscureText: false,
                  hinttext: "username",
                  prefixIcon: Icon(Icons.person),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: "Texxt",
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Bio
              SizedBox(
                width: 300,
                child: Customtextfile(
                  controller: bio,
                  prefixIcon: Icon(Icons.featured_play_list_rounded),
                  obscureText: false,
                  hinttext: "bio",
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: "Texxt",
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Profile picture picker & display
              Center(
                child: GestureDetector(
                  onTap: pickPfp,
                  child: CircleAvatar(
                    radius: 50,
                    child: ClipOval(
                      child : pfpImage !=null ? Image.file(pfpImage! , width: 100 , height: 100, fit: BoxFit.cover,)
                      : Image.asset('assets/images/pngwing.com.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
