import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:croydoncentralradio/utils/custom_color.dart';
import 'package:croydoncentralradio/utils/strings.dart';

import 'Helper/Constant.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

///splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ));
  }

  @override
  void initState() {
    super.initState();
    //getcityMode();


    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/image/icon.png',
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> getcityMode() async {
    var data = {'access_key': '6808'};
    var response = await http.post(city_mode, body: data);

    print("responce****city mode**${response.body.toString()}");

    var getdata = json.decode(response.body);

    var error = getdata['error'].toString();
    if (!mounted) return null;

    if (error == 'false') {
      var city = getdata['data'];

      if (city == "1") {
        cityMode = true;
      } else {
        cityMode = false;
      }

    } else {
      cityMode = false;
    }
  }
}
