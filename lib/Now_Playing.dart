import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:croydoncentralradio/utils/custom_color.dart';
import 'package:share/share.dart';
import 'package:volume_control/volume_control.dart';

import 'Helper/Constant.dart';
import 'main.dart';

///now playing inside class
class Now_Playing extends StatefulWidget {
  final VoidCallback _play, _pause, _next, _prev, _refresh;

  ///constructor
  Now_Playing(
      {VoidCallback play,
      VoidCallback pause,
      VoidCallback next,
      VoidCallback prev,
      VoidCallback refresh})
      : _play = play,
        _pause = pause,
        _next = next,
        _prev = prev,
        _refresh = refresh;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<Now_Playing> {

  void initState() {
    super.initState();
    initVolumeState();
  }

  //init volume_control plugin
  Future<void> initVolumeState() async {
    if (!mounted) return;

    //read the current volume
    _val = await VolumeControl.volume;
    setState(() {

    });
  }

  double _val = 0.5;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: curPlayList.isEmpty ? Container() : getContent());
  }
  getContent() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.primaryColor
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * .32,
            child: Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                    placeholder: NetworkImage(curPlayList[curPos].channelLogo
                    ),
                    image: NetworkImage(curPlayList[curPos].channelLogo),
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          Text(
            curPlayList[curPos].channelName,
            style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              curPlayList[curPos].description,
              style: Theme.of(context)
                  .textTheme
                  .subtitle
                  .copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ),
          getMiddleButton(),
          getMediaButton(),
          Slider(
            activeColor: Colors.white,

              value: _val,
              min:0,
              max:1,
              divisions: 100,
              onChanged:(val){
                _val = val;
                setState(() {});
                if (timer!=null){
                  timer.cancel();
                }

                //use timer for the smoother sliding
                timer = Timer(Duration(milliseconds: 200), (){VolumeControl.setVolume(val);});

                print("val:${val}");
              }),
          SizedBox(height: 20,)


        ],
      ),
    );
  }

  getMiddleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (Platform.isAndroid) {
                Share.share('I am listening to-\n'
                    '${curPlayList[curPos].channelName}\n'
                    '$appname\n'
                    'https://play.google.com/store/apps/details?id=$androidPackage&hl=en');
              } else {
                Share.share('I am listening to-\n'
                    '${curPlayList[curPos].channelName}\n'
                    '$appname\n'
                    '$iosPackage');
              }
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.queue_music),
            onPressed: () {
              panelController.close();
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  getMediaButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: CustomColor.primaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              width: MediaQuery.of(context).size.width - 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.fast_rewind),
                    iconSize: 35,
                    onPressed: widget._prev,
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(Icons.fast_forward),
                    iconSize: 35,
                    onPressed: widget._next,
                    color: Colors.white,
                  ),
                ],
              )),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.white12, offset: Offset(2, 2))
                    ],
                    shape: BoxShape.circle,
                    // Box decoration takes a gradient
                    gradient: LinearGradient(
                      // Where the linear gradient begins and ends
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      // Add one stop for each color. Stops should increase from 0 to 1
                      stops: [0.2, 0.5, 0.9],
                      colors: [
                        CustomColor.primaryColor.withOpacity(0.5),
                        CustomColor.primaryColor.withOpacity(0.7),
                        CustomColor.primaryColor,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:

                        (Platform.isIOS)
                            ? (isPlaying == true &&
                                    playerState == PlayerState.playing)
                                ? IconButton(
                                    icon: Icon(Icons.pause),
                                    iconSize: 50,
                                    color: Colors.white,
                                    onPressed: widget._pause)
                                : IconButton(
                                    icon: Icon(Icons.play_arrow),
                                    iconSize: 50,
                                    color: Colors.white,
                                    onPressed: widget._play)
                            : (duration == null &&
                                    playerState != PlayerState.stopped)
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white)),
                                  )
                                : IconButton(
                                    icon: Icon(isPlaying == true
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    iconSize: 50,
                                    color: Colors.white,
                                    onPressed: isPlaying == true
                                        ? widget._pause
                                        : widget._play,
                                  ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
