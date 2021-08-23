import 'dart:convert';

import 'package:croydoncentralradio/class/custom_loading.dart';
import 'package:croydoncentralradio/model/section_data.dart';
import 'package:croydoncentralradio/urls/endpoints.dart';
import 'package:croydoncentralradio/urls/urls.dart';
import 'package:croydoncentralradio/utils/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications'
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<SectionData>(
          future: _getSectionData(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              final notification = snapshot.data.data.notifications;
              return ListView.builder(
                itemCount: notification.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    color: CustomColor.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(
                          20
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notification[index].title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                '23 aug, 2021',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Text(
                            notification[index].description,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return CustomLoading();
          },
        ),
      ),
    );
  }

  Future<SectionData> _getSectionData () async {
    Uri url = Uri.parse('${Urls.mainUrl}${Endpoints.sectionData}');

    final response = await http.get(url);
    var data = jsonDecode(response.body);

    setState(() {

    });
    print('response: $data');
    return SectionData.fromJson(data);

  }
}
