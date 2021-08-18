import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomColor {
  static const Color primaryColor = Color(0xFF1c0707);
  static const Color secondaryColor = Color(0xFF1c0707);
  static const MaterialColor appBarColor = const MaterialColor(
    0xffe55f48, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: primaryColor,//10%
      100: primaryColor,//20%
      200: primaryColor,//30%
      300: primaryColor,//40%
      400: primaryColor,//50%
      500: secondaryColor,//60%
      600: const Color(0xff451c16),//70%
      700: const Color(0xff2e130e),//80%
      800: const Color(0xff170907),//90%
      900: const Color(0xff000000),//100%
    },
  );
}