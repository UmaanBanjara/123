import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feed/tabbars/following_tabview.dart';
import 'package:feed/tabbars/foryou_tabview.dart';
import 'package:feed/userposts/userposts.dart';
import 'package:flutter/material.dart';
import 'package:feed/presentation/profilescreen/profilepageuser.dart';
import 'package:feed/notification/notificationscreen.dart';
import 'package:feed/presentation/messagescreen/messagescreen.dart';
import 'package:feed/presentation/searchscreen/Searchscreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? error;

  // Fetch user details from backend using stored JWT token
  Future<void> getUserDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final url = Uri.parse('http://192.168.1.5:3000/getuserdetails');

    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        setState(() {
          error = "Authentication token not found.";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data['userDetails'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load user data: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error fetching user details: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = Theme.of(context).brightness == Brightness.light;
    final iconColor = iconTheme ? const Color(0XFF464F51) : Colors.yellow;

    final List<Widget> _mainScreens = [
      buildHomeTabView(),
      const Searchscreen(),
      const Notificationscreen(),
      const Messagescreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: buildDrawer(iconColor),
      body: _mainScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 300),
              child: const Posts(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Drawer buildDrawer(Color iconColor) {
    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: const UserProfile(),
                                duration: const Duration(milliseconds: 300),
                                reverseDuration: const Duration(milliseconds: 300),
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  userData?['profile_picture_url'] != null
                                      ? CachedNetworkImageProvider(
                                          userData!['profile_picture_url'])
                                      : const AssetImage(
                                              'assets/images/pngwing.com.png')
                                          as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: const UserProfile(),
                                duration: const Duration(milliseconds: 300),
                                reverseDuration: const Duration(milliseconds: 300),
                              ),
                            ),
                            child: Text(
                              userData?['username'] ?? 'Username',
                              style: const TextStyle(
                                fontFamily: "bOLD",
                                fontSize: 25,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${userData?['username'] ?? 'username'}.feeduser',
                            style: const TextStyle(
                              fontFamily: "lIGHT",
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                '${userData?['followers'] ?? 0} Followers',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "rEGULAR",
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${userData?['following'] ?? 0} Following',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "rEGULAR",
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Divider(),
                        ],
                      ),
          ),
          buildDrawerItem(Icons.home_filled, "Home", 0, iconColor),
          buildDrawerItem(Icons.search, "Search", 1, iconColor),
          buildDrawerItem(Icons.chat, "Messages", 3, iconColor),
          buildDrawerItem(Icons.notifications_active, "Notification", 2, iconColor),
          buildDrawerItem(Icons.person_4_outlined, "Profile", null, iconColor),
          buildDrawerItem(Icons.settings, "Settings", null, iconColor),
        ],
      ),
    );
  }

  ListTile buildDrawerItem(IconData icon, String title, int? index, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 25),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: "bOLD",
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 10),
      onTap: () {
        if (index != null) {
          setState(() {
            _selectedIndex = index;
          });
        }
        Navigator.pop(context);
      },
    );
  }

  Widget buildHomeTabView() {
    final TabController tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      appBar: AppBar(
        title: Text('f', style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            iconSize: 30,
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: userData?['profile_picture_url'] != null
                  ? CachedNetworkImageProvider(userData!['profile_picture_url'])
                  : const AssetImage("assets/images/pngwing.com.png")
                      as ImageProvider,
            ),
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'For you'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          ForyouTabview(),
          FollowingTabview(),
        ],
      ),
    );
  }
}
