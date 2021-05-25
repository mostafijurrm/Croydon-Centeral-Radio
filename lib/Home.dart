import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'All_Radio_Station.dart';
import 'Favorite.dart';
import 'Helper/Constant.dart';
import 'Helper/Model.dart';
import 'data/my_radio_station.dart';
import 'main.dart';

///category list
List<Model> catList = [];

///current slider position
int _curSlider = 0;

///slider list
///slider image list
List slider_image = [];

///favorite list size
int favSize = 0;

///is category loading
bool catloading = true;

///is error exist or not
bool errorExist = false;


///home class
class Home extends StatefulWidget {
  VoidCallback _play, _pause, _next, _previous;

  ///constructor
  Home(
      {VoidCallback play,
      VoidCallback pause,
      VoidCallback next,
      VoidCallback previous})
      : _play = play,
        _pause = pause,
        _next = next,
        _previous = previous;

  _Home_State createState() => _Home_State();
}

class _Home_State extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(bottom: 200.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getLabel('Category'),
                        getLabel('Latest'),
                        getLatest(),
                        getFavorite(),
                      ],
                    ),
                  ),
                ),
              ),
              /*AdmobBanner(
                adUnitId: getBannerAdUnitId(),
                adSize: AdmobBannerSize.BANNER,
              ),*/
            ],
          )),
    );
  }


  @override
  void initState() {
    super.initState();

    getCategory();
  }

  Widget getFavorite() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none ||
              projectSnap.data == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            favSize = int.parse(projectSnap.data.length.toString());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                favSize == 0
                    ? Container(
                        height: 0,
                      )
                    : getLabel('Favorites'),
                Container(
                    height: favSize == 0 ? 10 : 150,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        itemCount: int.parse(
                                    projectSnap.data.length.toString()) >
                                0
                            ? int.parse(projectSnap.data.length.toString()) >=
                                    10
                                ? 10
                                : int.parse(projectSnap.data.length.toString())
                            : 0,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  '${projectSnap.data[i].image}')),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(2, 2))
                                          ],
                                        ))),
                                Container(
                                  // color: primary.withOpacity(0.2),
                                  width: 100,
                                  child: Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Text(
                                      '${projectSnap.data[i].name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ],
                            ),
                            onTap: () {
                              curPos = i;
                              curPlayList = projectSnap.data as List<MyRadioStation>;
                              url =
                                  projectSnap.data[curPos].radio_url.toString();

                              //  print("current url**$url");

                              position = null;
                              duration = null;

                              if (url.isNotEmpty) {
                                widget._play();
                              }
                            },
                          );
                        }))
              ],
            );
          }
        },
        future: db.getAllFav(),
      ),
    );
  }

  Future getCategory() async {
    var data = {
      'access_key': '6808',
    };
    var response = await http.post(cat_api, body: data);

    print('responce*****cat${response.body.toString()}');

    var getData = json.decode(response.body);

    var error = getData['error'].toString();

    setState(() {
      catloading = false;
      if (error == 'false') {
        var data1 = (getData['data']);
        // catList = (data as List).map((Map<String, dynamic>) => Model.fromJson(data)).toList();

        catList = (data1 as List)
            .map((data) => Model.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        errorExist = true;
      }
    });
  }

  Widget getLabel(String cls) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              cls,
              style: Theme.of(context).textTheme.title,
            ),
            GestureDetector(
              child: Text(
                'See more',
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: primary, decoration: TextDecoration.underline),
              ),
              onTap: () {
                if (cls == 'Category') {
                  tabController.animateTo(1);
                } else if (cls == 'Latest') {
                  tabController.animateTo(2);
                } else if (cls == 'Favorites') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Favorite(
                            play: widget._play,
                            pause: widget._pause,
                            next: widget._next,
                            previous: widget._previous),
                      ));
                }
              },
            ),
          ],
        ));
  }

  Widget getLatest() {
    var length = int.parse(radioList.length.toString());

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
            height: 130,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: length > 0 ? length > 10 ? 10 : length : 0,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          '${radioList[i].image}')),
                                  borderRadius: BorderRadius.circular(50.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(2, 2))
                                  ],
                                ))),
                        Container(
                          // color: primary.withOpacity(0.2),
                          width: 100,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              '${radioList[i].name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                    onTap: () {
                      curPos = i;
                      curPlayList = radioList;
                      url = radioList[curPos].radio_url;

                      position = null;
                      duration = null;
                      widget._play();
                    },
                  );
                })));
  }
}
