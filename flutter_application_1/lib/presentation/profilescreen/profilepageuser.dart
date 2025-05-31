import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    final url = Uri.parse('http://192.168.1.5:3000/getuserdetail');

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print('JWT token not found');
        return;
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data['user'];
          isLoading = false;
        });
      } else {
        print('Failed to fetch user details');
      }

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 6.5,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.grey.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                              color: Colors.grey[300],
                              image: userData!['banner_url'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(userData!['banner_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            top: 70,
                            left: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.grey.withOpacity(0.6)
                                        : Colors.black.withOpacity(0.4),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                backgroundImage:
                                    userData!['profile_picture_url'] != null
                                        ? NetworkImage(userData!['profile_picture_url'])
                                        : const AssetImage("assets/images/pngwing.com.png")
                                            as ImageProvider,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 118,
                            right: 5,
                            child: ElevatedButton(
                              onPressed: () {
                                // Implement edit functionality
                              },
                              child: const Text('Edit profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, top: 8),
                      child: Text(
                        (userData!['username'] ?? '').split('.').first.trim(),
                        style: const TextStyle(
                          fontFamily: "Primary",
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 4),
                      child: Text(
                        '@${userData!['username'] ?? ''}',
                        style: TextStyle(
                          fontFamily: "texxt",
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: isDark ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                      child: Text(
                        (userData!['bio'] ?? '').isEmpty
                            ? "No bio provided."
                            : userData!['bio'],
                        style: const TextStyle(
                          fontFamily: "texxt",
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Joined date as-is with calendar icon
                    if (userData?['created_at'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.white : Colors.black),
                            const SizedBox(width: 5),
                            Text(
                              'Joined ${userData!['created_at']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            '${userData?['followers'] ?? 0} Followers',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${userData?['following'] ?? 0} Following',
                            style: const TextStyle(fontSize: 15),
                          ),
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
