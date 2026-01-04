import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restaurant_app/screens/main_screen.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/restaurant_splash';

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      backgroundColor: Colors.white,
      splash: _buildImage(context),
      nextScreen: MainScreen(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
    );
  }

  Widget _buildImage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Icon(Icons.fastfood, size: 80.0, color: Colors.cyan[600]),
        ),
        SizedBox(height: 170.0),
        Expanded(
          flex: 1,
          child: AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(
                'Loading...',
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.cyan[600],
                ),
              ),
            ],
            isRepeatingAnimation: true,
          ),
        ),
      ],
    );
  }
}
