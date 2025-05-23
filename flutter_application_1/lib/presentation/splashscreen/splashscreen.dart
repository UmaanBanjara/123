import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:feed/presentation/choosemodescreen/choosemodescreen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Splashscreendark extends StatefulWidget {
  const Splashscreendark({super.key});

  @override
  State<Splashscreendark> createState() => _SplashscreendarkState();
}

class _SplashscreendarkState extends State<Splashscreendark> {
  

  bool showfirsttext = false ; 
   



 
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        showfirsttext = true ; 
         
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: showfirsttext ? AnimatedTextKit(
          animatedTexts: [
            RotateAnimatedText(
              "FEED",
              textStyle: const TextStyle(
                fontSize: 50,
                color: Color(0xFFF8FAFC),
                fontWeight: FontWeight.bold,
                fontFamily: "Primary",
                letterSpacing: 3,
              ),
            ),
            RotateAnimatedText(
              '"Scroll to decode"',
              textStyle: const TextStyle(
                fontSize: 20,
                letterSpacing: 3,
                color: Color(0xFFFFD700),
                fontFamily: "Secondary",
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          isRepeatingAnimation: false,
          totalRepeatCount: 1,
          pause: const Duration(milliseconds: 1000),
          onFinished: () => Navigator.push(context , PageTransition(
            type : PageTransitionType.fade,
            child : ImageAnimationScreen(),
            duration: Duration(milliseconds: 300),
            reverseDuration: Duration(milliseconds: 300)
          ))
        ) : SizedBox() ,
      
    ) );
  }
}
