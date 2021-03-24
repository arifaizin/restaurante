import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restaurant_app/screens/main_screen.dart';
import 'package:restaurant_app/util/constants.dart';

class SplashScreen extends StatelessWidget {

  static const routeName = '/restaurant_splash';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSplashScreen(
        duration: 3000,
        backgroundColor: Colors.white,
        splash: _buildImage(context),
        nextScreen: MainScreen(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.bottomToTop,
      ),
    );
  }

  Container _buildImage(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 40.0, right: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.fastfood,
              size: 150.0,
              color: Theme.of(context).accentColor,
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                top: 15.0,
              ),
              child: WavyAnimatedTextKit(
                textStyle: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).accentColor,
                ),
                text: ["Loading..."],
                isRepeatingAnimation: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
