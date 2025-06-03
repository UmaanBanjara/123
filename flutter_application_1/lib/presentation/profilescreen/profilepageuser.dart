import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feed/editpage/editpage.dart';
import 'package:feed/presentation/homescreen/homescreen.dart';
import 'package:feed/tabbars/posts_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with TickerProviderStateMixin {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  late TabController _tabController;

  final List<Tab> myTabs = [
    const Tab(text: 'Post' ,),
    const Tab(text: 'Replies'),
    const Tab(text: 'Likes'),
    const Tab(text: 'Media'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
    getUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatJoinDate(String rawDate) {
    try {
      final parsedDate = DateTime.parse(rawDate);
      return DateFormat.yMMMM().format(parsedDate); // Example: June 2025
    } catch (e) {
      return rawDate; // fallback if parsing fails
    }
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
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  void _goToEditPage() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        child: const EditPage(),
      ),
    );
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        child: const Homescreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 160,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: _goToEditPage,
                                    child: Container(
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
                                        image: userData?['banner_url'] != null
                                            ? DecorationImage(
                                                image: CachedNetworkImageProvider(userData!['banner_url']),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 8,
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back,
                                          color: isDark ? Colors.white : Colors.white),
                                      onPressed: _goToHomeScreen,
                                    ),
                                  ),
                                  Positioned(
                                    top: 70,
                                    left: 12,
                                    child: GestureDetector(
                                      onTap: _goToEditPage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.grey.withOpacity(0.2)
                                                  : Colors.black.withOpacity(0.4),
                                              blurRadius: 8,
                                            )
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.grey.withOpacity(0.2),
                                          backgroundImage: userData?['profile_picture_url'] != null
                                              ? CachedNetworkImageProvider(userData!['profile_picture_url'])
                                              : const AssetImage("assets/images/pngwing.com.png")
                                                  as ImageProvider,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 123,
                                    right: 5,
                                    child: ElevatedButton(
                                      onPressed: _goToEditPage,
                                      child:  Text('Edit profile'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18, top: 3),
                              child: Text(
                                (userData?['username'] ?? '').split('.').first.trim(),
                                style: const TextStyle(
                                  fontFamily: "bOLD",
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 17, top: 2),
                              child: Text(
                                '@${userData?['username'] ?? ''}.feeduser',
                                style: TextStyle(
                                  fontFamily: "lIGHT",
                                  fontSize: 15,
                                  color : Colors.grey
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                              child: Text(
                                (userData?['bio'] ?? '').isEmpty
                                    ? "No bio provided."
                                    : userData!['bio'],
                                style: const TextStyle(
                                  fontFamily: "rEGULAR",
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (userData?['create_at'] != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 9),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16,
                                        color: isDark ? Colors.grey : Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Joined ${_formatJoinDate(userData!['create_at'])}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: "rEGULAR",
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Row(
                                children: [
                                  Text(
                                    '${userData?['followers'] ?? 0} Followers',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "rEGULAR",
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${userData?['following'] ?? 0} Following',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "rEGULAR",
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            tabs: myTabs,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                        
                            
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      PostsTabbar(),
                      Center(child: Text('Replies content')),
                      Center(child: Text('Likes content')),
                      Center(child: Text('Media content')),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
