import 'dart:async';
import 'dart:convert';
import 'package:croydoncentralradio/class/custom_loading.dart';
import 'package:croydoncentralradio/model/general_data.dart';
import 'package:croydoncentralradio/urls/endpoints.dart';
import 'package:croydoncentralradio/urls/urls.dart';
import 'package:croydoncentralradio/utils/strings.dart';
import 'package:flutter/material.dart';

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



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<GeneralData> (
        future: _getGeneralData(),
        builder: (context, snapshot) {
          if(snapshot.hasData)  {
            final data = snapshot.data.data;
            startTime();
            Strings.appName = data.sitename;
            return Center(
              child: CircleAvatar(
                radius: 200,
                backgroundImage: NetworkImage(
                    data.icon
                ),
              ),
            );
          }
          return CustomLoading();
        },
      ),
    );
  }

  Future<GeneralData> _getGeneralData () async {
    Uri url = Uri.parse('${Urls.mainUrl}${Endpoints.generalData}');

    final response = await http.get(url);
    var data = jsonDecode(response.body);

    print('response: $data');
    return GeneralData.fromJson(data);

  }
}
