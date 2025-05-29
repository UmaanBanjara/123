      import 'dart:io';
      import 'package:flutter/material.dart';
      import 'package:feed/notification/notificationscreen.dart';
      import 'package:feed/presentation/messagescreen/messagescreen.dart';
      import 'package:feed/presentation/searchscreen/Searchscreen.dart';

      class Homescreen extends StatefulWidget {
        final File? pfpImage;
        final String username ;
        final String bio;


        const Homescreen({Key? key, this.pfpImage , required this.username , required this.bio}) : super(key: key);

        @override
        State<Homescreen> createState() => _HomescreenState();
      }

      class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
        int _selectedIndex = 0;

        final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

        @override
        Widget build(BuildContext context) {
          final iconTheme = Theme.of(context).brightness == Brightness.light;
          final iconColor = iconTheme ? const Color(0XFF464F51) : Colors.yellow;
          final List<Widget> _mainScreens = [
            buildHomeTabView(),
            Searchscreen(),
            Notificationscreen(),
            Messagescreen(),
          ];

          return Scaffold(
            key : _scaffoldkey ,
            drawer: Drawer(
              backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.pfpImage != null
                            ? CircleAvatar(
                                radius: 28,
                                backgroundImage: FileImage(widget.pfpImage!),
                              )
                            : const CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    AssetImage('assets/images/pngwing.com.png'),
                              ),
                        const SizedBox(height: 12),
                        Text(
                            widget.username.split('.').first.trim(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Primary",
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.username}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Text(
                              '6 Followers',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '6 Following',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Divider(),
                      ],
                    ),
                  ),

                  ListTile(
                    leading: Icon(Icons.home_filled, color: iconColor, size: 30),
                    title: const Text(
                      "Home",
                      style: TextStyle(
                          fontFamily: "Primary",
                          fontSize: 30,
                          fontWeight: FontWeight.normal),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.search, color: iconColor, size: 30),
                    title: const Text(
                      "Search",
                      style: TextStyle(
                          fontFamily: "Primary",
                          fontSize: 30,
                          fontWeight: FontWeight.normal),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.chat, color: iconColor, size: 30),
                    title: const Text(
                      "Messages",
                      style: TextStyle(
                          fontFamily: "Primary",
                          fontSize: 30,
                          fontWeight: FontWeight.normal),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.notifications_active, color: iconColor, size: 30),
                    title: const Text(
                      "Notification",
                      style: TextStyle(
                          fontFamily: "Primary",
                          fontSize: 30,
                          fontWeight: FontWeight.normal),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.person_4_outlined, color: iconColor, size: 30),
                    title: const Text(
                      "Profile",
                      style: TextStyle(
                          fontFamily: "Primary",
                          fontSize: 30,
                          fontWeight: FontWeight.normal),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10),
                    onTap: () {
                      // Implement profile navigation if needed
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.settings, color: iconColor, size: 30),
                    title: const Text(
                      "Settings",
                      style: TextStyle(
                          fontFamily: "Primary",
                          fontSize: 30,
                          fontWeight: FontWeight.normal),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10),
                    onTap: () {
                      // Implement settings navigation if needed
                      Navigator.pop(context);
                    },
                  ),

                
                ],
              ),
            ),
            body: _mainScreens[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.notifications), label: 'Notifications'),
                BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
              ],
            ),
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
            child: widget.pfpImage != null
            ? GestureDetector(
                onTap: () {
                  _scaffoldkey.currentState?.openDrawer();
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: FileImage(widget.pfpImage!),
                ),
              )
            : GestureDetector(
                onTap: () {
                  _scaffoldkey.currentState?.openDrawer();
                },
                child: const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/images/pngwing.com.png'),
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
                Center(child: Text('Content for For You tab')),
                Center(child: Text('Content for Following tab')),
              ],
            ),
          );
        }
      }
