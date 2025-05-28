  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:feed/notification/notificationscreen.dart';
  import 'package:feed/presentation/messagescreen/messagescreen.dart';
  import 'package:feed/presentation/searchscreen/Searchscreen.dart';

  class Homescreen extends StatefulWidget {
    final File? pfpImage;

    const Homescreen({Key? key, this.pfpImage}) : super(key: key);

    @override
    State<Homescreen> createState() => _HomescreenState();
  }

  class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
    int _selectedIndex = 0;

    @override
    Widget build(BuildContext context) {
      final List<Widget> _mainScreens = [
        buildHomeTabView(),       // Home screen with TabBar
        Searchscreen(),           // Other screens
        Notificationscreen(),
        Messagescreen(),
      ];

      return Scaffold(
        drawer: Drawer(

          backgroundColor: Theme.of(context).drawerTheme.backgroundColor,

          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    
                    color: Theme.of(context).scaffoldBackgroundColor,   
                  ),
                  child : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                
                    children: [
                      widget.pfpImage != null ? CircleAvatar(
                        radius: 16,
                        backgroundImage: FileImage(widget.pfpImage!),
                      ) : CircleAvatar(
                        radius: 23,
                        backgroundImage: AssetImage('assets/images/pngwing.com.png'),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    Text('User Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , fontFamily: "Primary")),
                    Text('@username', style: TextStyle( fontSize: 13  ,color: Colors.grey)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '6 Followers',
                          style: TextStyle(
                            fontSize: 11
                          ),
                        ),

                        SizedBox(width: 5,),
                        Text(
                          '6 Followings',
                          style: TextStyle(
                            fontSize: 11
                          ),

                        ),
                      ],
                    )

                    ],
                  )
                ),
              )
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
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
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
              icon: Icon(Icons.more_vert),
              iconSize: 30,
            ),
          ],
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: widget.pfpImage != null
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: FileImage(widget.pfpImage!),
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/pngwing.com.png'),
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
