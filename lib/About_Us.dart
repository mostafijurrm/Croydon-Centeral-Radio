import 'package:flutter/material.dart';
import 'package:croydoncentralradio/utils/strings.dart';

class AboutUS extends StatefulWidget {
  @override
  _aboutState createState() => _aboutState();
}

class _aboutState extends State<AboutUS> {
  String _privacy;
  String _loading = "true";


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us'),centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          Strings.aboutUsDetails,
          style: TextStyle(
            fontSize: 18
          ),
        ),
      ),
    );
  }


}
