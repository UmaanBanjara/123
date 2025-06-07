import 'package:feed/data/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageAnimationScreen extends StatefulWidget {
  @override
  _ImageAnimationScreenState createState() => _ImageAnimationScreenState();
}

class _ImageAnimationScreenState extends State<ImageAnimationScreen> {
  bool areHandsPositioned = false; // Tracks if hands have positioned
  bool areIconsPositioned = false; // Tracks if icons have positioned
  bool isdark = false;

  @override
  void initState() {
    super.initState();
    // Trigger the hand animation after a delay
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        areHandsPositioned = true;
      });

      // Trigger the icon animation after the hands are positioned
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          areIconsPositioned = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show toggle when both animations are done
    bool showToggle = areHandsPositioned && areIconsPositioned;

    return Scaffold(
      body: Stack(
        children: [
          // Background color changes based on isdark
          Container(
            color: isdark ? Colors.black : Colors.white,
          ),

          // Left hand animation
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            left: areHandsPositioned
                ? MediaQuery.of(context).size.width / 4 - 50
                : -100, // From the left side
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: Image.asset('assets/images/lefthand.png', width: 150),
          ),

          // Right hand animation
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            right: areHandsPositioned
                ? MediaQuery.of(context).size.width / 4 - 50
                : -100, // From the right side
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: Image.asset('assets/images/righthand.png', width: 150),
          ),

          // Left icon animation (top-left corner to left hand)
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            top: areIconsPositioned
                ? MediaQuery.of(context).size.height / 2 - 60
                : -100, // From the top
            left: areIconsPositioned
                ? MediaQuery.of(context).size.width / 4 - 5
                : -100,
            child: Image.asset('assets/images/sun.png', width: 50),
          ),

          // Right icon animation (bottom-right corner to right hand)
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            bottom: areIconsPositioned
                ? MediaQuery.of(context).size.height / 2 + 13
                : -100, // From the bottom
            right: areIconsPositioned
                ? MediaQuery.of(context).size.width / 4 - 5
                : -100,
            child: Image.asset('assets/images/moon.png', width: 50),
          ),

          // Show toggle and button only after animations finish
          if (showToggle)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "LIGHT",
                          style: TextStyle(
                            color: isdark ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Switch(
                          value: isdark,
                          activeColor: Colors.yellow,
                          activeTrackColor: Colors.yellow.shade400,
                          inactiveThumbColor: Color(0xFFDEFFF2),
                          inactiveTrackColor:
                              Color(0xFFDEFFF2).withOpacity(0.4),
                          onChanged: (value) {
                            setState(() {
                              isdark = value;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          "DARK",
                          style: TextStyle(
                            color: isdark ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                        print('Choose button pressed');
                      },
                      child: Text('Choose'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ));
  }
}
