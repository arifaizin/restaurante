import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

  Container _buildImage(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Lottie.asset('assets/8438-mr-cookie-drink.json', fit: BoxFit.cover),
    );
  }
}
