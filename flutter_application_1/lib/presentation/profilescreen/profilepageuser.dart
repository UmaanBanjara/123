import 'dart:io';

import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final File? pfpImage;
  final File? bannerImage;
  final String username;
  final String bio;

  const UserProfile(this.bannerImage, this.pfpImage, this.username, this.bio, {super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final bool isdark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack for banner, profile pic and edit button
              SizedBox(
                height: 160, // Adjust to fit banner + profile pic overlap nicely
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    // Banner image
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 6.5,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isdark ? Colors.grey.withOpacity(0.6) : Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: widget.bannerImage != null
                          ? Image.file(widget.bannerImage!, fit: BoxFit.cover)
                          : Container(color: Colors.grey.withOpacity(0.2)),
                    ),

                    // Profile picture positioned overlapping banner
                    Positioned(
                      top: 70,
                      left: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isdark ? Colors.grey.withOpacity(0.6) : Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          backgroundImage: widget.pfpImage != null
                              ? FileImage(widget.pfpImage!)
                              : AssetImage("assets/images/pngwing.com.png") as ImageProvider,
                        ),
                      ),
                    ),

                    // Edit profile button on top right
                    Positioned(
                      top: 118,
                      right: 5,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Edit profile'),
                      ),
                    ),
                  ],
                ),
              ),

              // Username
              Padding(
                padding: const EdgeInsets.only(left: 18, ),
                child: Text(
                  widget.username.split('.').first.trim(),
                  style: const TextStyle(fontFamily: "Primary", fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),

              // @username
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 4),
                child: Text(
                  '@${widget.username}',
                  style: TextStyle(
                    fontFamily: "texxt",
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: isdark ? Colors.grey : Colors.black,
                  ),
                ),
              ),

              // Bio — can be empty or long, controls spacing below
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Text(
                  widget.bio.isEmpty ? "No bio provided." : widget.bio,
                  style: const TextStyle(fontFamily: "texxt", fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),

              const SizedBox(height: 14),

              // Followers and Following row
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: const [
                    Text('6 Followers', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 12),
                    Text('6 Following', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
