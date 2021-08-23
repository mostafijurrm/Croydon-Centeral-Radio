import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_review/app_review.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:croydoncentralradio/Splash.dart';
import 'package:croydoncentralradio/class/url_launcher.dart';
import 'package:croydoncentralradio/model/section_data.dart';
import 'package:croydoncentralradio/screens/notifications_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_radio_player/flutter_radio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:phone_state_i/phone_state_i.dart';
import 'package:croydoncentralradio/utils/custom_color.dart';
import 'package:croydoncentralradio/utils/strings.dart';

import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'About_Us.dart';
import 'All_Radio_Station.dart';
import 'BottomPanel.dart';
import 'Helper/Constant.dart';
import 'Helper/Favourite_Helper.dart';
import 'Helper/Model.dart';
import 'Now_Playing.dart';

void main() {
  //Admob.initialize(getAppId());
  runApp(MyApp());
}

///root of your application, starting point of execution
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio App',
      theme: ThemeData(
        primarySwatch: CustomColor.appBarColor,
      ),
      home: Directionality(
        textDirection: direction, // set this property
        child: Splash(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

///all radio station is loading
bool loading = true;

///offset for load more
int offset = 0;

///total radio station
int total = 0;

///no of item to load in one time
int perPage = 10;

///temp radio list for load more
List<ChannelDatum> tempSongList = [];

///is error exist
bool errorExist = false;

///search list
List<Model> searchList = [];

///favorite database
var db = Favourite_Helper();

///bottom panel
PanelController panelController;

///after search result list
///currently is searching
bool isSearching;

///home tab controller
TabController tabController;

///main contianer of app
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription _streamSubscription;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  DateTime _currentBackPressTime;
  FlutterRadioPlayer _flutterRadioPlayer = new FlutterRadioPlayer();

  Icon iconSearch = Icon(
    Icons.search,
    color: Colors.white,
  );

  Widget appBarTitle = Text(
    Strings.appName,
    style: TextStyle(color: Colors.white),
  );

  _MyHomePageState() {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (!mounted) return;
        setState(() {
          isSearching = false;
          // _searchText = "";
        });
      } else {
        isSearching = true;
        // _searchText = _controller.text;
      }
    });
  }

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    isSearching = false;
    panelController = PanelController();
    // Initialize the Tab Controller
    tabController = TabController(length: 1, vsync: this);
    // firebaseCloudMessaging_Listeners();

    tempSongList.clear();
    radioList.clear();

    getRadioStation();
    loading = false;
    initAudioPlayer();

    AudioPlayer.logEnabled = false;

    firNotInitialize();

    handlePhoneCall();
    _openNotification();
  }

  @override
  void dispose() {
    // print("disposing");
    _streamSubscription.cancel();

    if (!panelController.isPanelClosed()) {
      panelController.close();
    }
    // Dispose of the Tab Controller
    tabController.dispose();

    playerState = PlayerState.stopped;
    audioPlayer.stop();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    playerStateSubscription?.cancel();

    super.dispose();
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {
    return showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(25.0),
      topRight: Radius.circular(25.0),
    );

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            key: _globalKey,
            appBar: getAppbar(),
            drawer: getDrawer(),
            body: SlidingUpPanel(
                borderRadius: radius,
                panel: Now_Playing(
                  play: _play,
                  pause: _pause,
                  next: _next,
                  prev: _previous,
                  refresh: _refresh,
                ),
                minHeight: 65,
                controller: panelController,
                maxHeight: MediaQuery.of(context).size.height,
                backdropEnabled: true,
                backdropOpacity: 0.5,
                parallaxEnabled: true,
                collapsed: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: radius),
                    child: BottomPanel(
                      play: _play,
                      pause: _pause,
                    ),
                  ),
                  onTap: () {
                    panelController.open();
                  },
                ),
                body: getTabBarView(<Widget>[
                  Directionality(
                    textDirection: direction, // set this property
                    child: Radio_Station(
                      play: _play,
                      getCat: getRadioStation,
                      refresh: _refresh,
                      textController: _controller,
                    ),
                  ),
                ])
            )
        )
    );
  }

  Future<bool> _onWillPop() async {

    if (!panelController.isPanelClosed()) {
      panelController.close();
      return Future<bool>.value(false);
    } else if (_globalKey.currentState.isDrawerOpen) {
      Navigator.pop(context); // closes the drawer if opened
      return Future.value(false); // won't exit the app
    } else {
      // dispose();
      //return Future.value(true);

      var now = DateTime.now();
      if (_currentBackPressTime == null ||
          now.difference(_currentBackPressTime) > Duration(seconds: 2)) {
        _currentBackPressTime = now;
        _globalKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Double tap to exit app',
            textAlign: TextAlign.center,
          ),
          backgroundColor: CustomColor.primaryColor,
          behavior: SnackBarBehavior.floating,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ));
        return Future.value(false);
      }
      dispose();
      return Future.value(true);
    }
  }

  TabBarView getTabBarView(List<Widget> tabs) {
    return TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: tabController,
      //  dragStartBehavior: DragStartBehavior.down,
    );
  }

  TabBar getTabBar() {
    return TabBar(
      tabs: <Tab>[
        Tab(
          text: Strings.allStation,
        ),
        /*Tab(
          text: cityMode ? 'City' : 'Category',
        ),
        Tab(
          text: 'All Radio',
        ),*/
      ],
      // setup the controller
      controller: tabController,
    );
  }

  void getRadioStation() async {

    radioList.addAll(tempSongList);

    //curPlayList = radioList;
    // curPlayList = ChannelDatum() as List;

    url = curPlayList[1].radioUrl;
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer(mode: mode);

    durationSubscription = audioPlayer.onDurationChanged.listen((duration1) {
      //print("duration change***$duration1");
      if (!mounted) {
        return;
      }
      setState(() => duration = duration1);

      // if (Theme.of(context).platform == TargetPlatform.iOS) {
      if (Platform.isIOS) {
        // set atleast title to see the notification bar on ios.
        audioPlayer.startHeadlessService();

        audioPlayer.setNotification(
            title: '$appname',
            artist: '${curPlayList[curPos].description}',
            //albumTitle: '${curPlayList[curPos].cat_name}',
            imageUrl: '${curPlayList[curPos].channelLogo}',
            forwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            backwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            duration: duration1,
            elapsedTime: Duration(seconds: 0));
      }
    });

    positionSubscription =
        audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          position = p;
        }));

    playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((event) {
      _next();
      if (!mounted) {
        return;
      }
      setState(() {
        position = duration;
      });
    });

    playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
      // print('audioPlayer error : $msg');
      if (!mounted) {
        return;
      }
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      // print('audioPlayer state : $state');

      if (!mounted) {
        return;
      }
      setState(() {
        audioPlayerState = state;
      });
    });
    //  AudioPlayer.logEnabled = true;
    audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => audioPlayerState = state);
    });
  }

  void _next() async {
    curPos = curPos + 1;
    if (curPos < curPlayList.length) {
      final result = await audioPlayer.pause();
      if (result == 1) setState(() => playerState = PlayerState.paused);

      position = null;
      duration = null;
      url = curPlayList[curPos].radioUrl;
      _play();
    } else {
      curPos = curPos - 1;
    }
  }

  void _previous() {
    curPos = curPos - 1;
    if (curPos >= 0) {
       _pause();
      audioPlayer.pause();
      position = null;
      duration = null;
      url = curPlayList[curPos].radioUrl;
      _play();
    } else {
      curPos = curPos + 1;
    }
  }

  void _play() async {
    final playPosition = (position != null &&
        duration != null &&
        position.inMilliseconds > 0 &&
        position.inMilliseconds < duration.inMilliseconds)
        ? position
        : null;

    print("play current**$url");
    final result =
    await audioPlayer.play(url, isLocal: isLocal, position: playPosition);
    if (!mounted) {
      return;
    }
    if (result == 1) {
      setState(() {
        playerState = PlayerState.playing;
      });
    }

    if (Platform.isIOS) {
      await audioPlayer.setPlaybackRate(playbackRate: 1.0);
    }
  }

  void _pause() async {

    if(Platform.isIOS){
      final result = await audioPlayer.pause();
      if (result == 1) {
        setState(() => playerState = PlayerState.paused);
      }
    }else {
      if (duration != null) {
        final result = await audioPlayer.pause();
        if (result == 1) {
          setState(() => playerState = PlayerState.paused);
        }
      }
    }
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> searchOperation(String searchText) async {
    if (isSearching != null) {
      var data = {'access_key': '6808', 'keyword': searchText};

      var response = await http.post('$search_api', body: data);
      var getdata = json.decode(response.body);

      var error = getdata['error'].toString();

      if (error == 'false') {
        //searchresult.clear();
        searchList.clear();

        var data = (getdata['data']);

        searchList = (data as List)
            .map((data) => Model.fromJson(data as Map<String, dynamic>))
            .toList();
      }

      for (var i = 0; i < searchList.length; i++) {
        Model data = searchList[i];

        if (data.name.toLowerCase().contains(searchText.toLowerCase())) {
          //searchresult.add(data);
        }
      }
      if (!mounted) return;
      setState(() {});
    }
  }

  void _handleSearchStart() {
    if (!mounted) return;
    setState(() {
      isSearching = true;
      tabController.animateTo(2);
      //_myTabbedPageKey.currentState.tabController.animateTo(2);
    });
  }

  void _handleSearchEnd() {
    if (!mounted) return;
    setState(() {
      iconSearch = Icon(
        Icons.search,
        color: Colors.white,
      );
      appBarTitle = Text(
        appname,
        style: TextStyle(color: Colors.white),
      );
      isSearching = false;
      _controller.clear();
      //searchresult.clear();
    });
  }

  void firNotInitialize() {
    ///for firebase push notification
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void handlePhoneCall() {
    _streamSubscription = phoneStateCallEvent.listen((event) {
      //  print('Call is Incoming/Connected ' + event.stateC);

      var state = event.stateC;

      if (state.compareTo('true') == 0) {
        _pause();
        //print('Call is Incoming/Connected ' + event.stateC);
      } else {
        // print('Call is Incoming/Connected not' + event.stateC);

      }
    });
  }

  AppBar getAppbar() {
    return AppBar(
      title: appBarTitle,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                CustomColor.secondaryColor,
                CustomColor.primaryColor.withOpacity(0.8),
                CustomColor.primaryColor.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.15, 0.5, 0.7]),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: Colors.white
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen()));
          },
        )
      ],
      bottom: getTabBar(),
      /*actions: <Widget>[
        IconButton(
          icon: iconSearch,
          onPressed: () {
            //print("call search");
            if (!mounted) return;
            setState(() {
              if (iconSearch.icon == Icons.search) {
                iconSearch = Icon(
                  Icons.close,
                  color: Colors.white,
                );
                appBarTitle = TextField(
                  controller: _controller,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  onChanged: searchOperation,
                );
                _handleSearchStart();
              } else {
                _handleSearchEnd();

                //print("cur list**${curPlayList.length}");
              }
            });
          },
        )
      ],*/
    );
  }

  Drawer getDrawer() {
    return Drawer(
      child: Container(
          decoration: BoxDecoration(
            color: Colors.black
          ),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Image.asset(
                'assets/image/icon.png',
                width: MediaQuery.of(context).size.width,
                height: 200,
              ),
              /*ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    tabController.animateTo(0);
                  }),*/
              SizedBox(height: 50,),
              ListTile(
                  leading: Icon(
                      FontAwesomeIcons.facebook,
                      color: Colors.white
                  ),
                  title: Text(
                    'Facebook',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncher.url(Strings.facebookUrl);
                  }),
              ListTile(
                  leading: Icon(
                      FontAwesomeIcons.twitter,
                      color: Colors.white
                  ),
                  title: Text(
                    'Twitter',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncher.url(Strings.twitterUrl);
                  }),
              /*ListTile(
                  leading: Icon(Icons.radio, color: Colors.white),
                  title: Text(
                    'All Radio',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    tabController.animateTo(2);
                  }),*/
              /*ListTile(
                  leading: Icon(Icons.favorite, color: Colors.white),
                  title: Text(
                    'Favourite',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Directionality(
                            textDirection: direction,
                            // set this property
                            child: Favorite(
                              play: _play,
                              pause: _pause,
                              next: _next,
                              previous: _previous,
                            ),
                          ),
                        ));
                  }),*/
              ListTile(
                  leading: Icon(Icons.share, color: Colors.white),
                  title: Text(
                    'Share App',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (Platform.isAndroid) {
                      Share.share('I am listening to-\n'
                          '$appname\n'
                          'https://play.google.com/store/apps/details?id=$androidPackage&hl=en');
                    } else {
                      Share.share('I am listening to-\n'
                          '$appname\n'
                          '$iosPackage');
                    }
                  }),
              ListTile(
                  leading: Icon(Icons.info, color: Colors.white),
                  title: Text(
                    'About Us',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Directionality(
                              textDirection: direction,
                              // set this property
                              child: AboutUS()),
                        ));
                  }),
              ListTile(
                  leading: Icon(Icons.star, color: Colors.white),
                  title: Text(
                    'Rate App',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    AppReview.requestReview.then((onValue) {});
                  }),
            ],
          )),
    );
  }

  _openNotification() async {
    final mediaItem = MediaItem(
      id: "https://foo.bar/baz.mp3",
      album: "Foo",
      title: "Bar",
    );
    // Tell the UI and media notification what we're playing.
    AudioServiceBackground.setMediaItem(mediaItem);
    // Listen to state changes on the player...
   /* audioPlayer.playerStateStream.listen((playerState) {
      // ... and forward them to all audio_service clients.
      AudioServiceBackground.setState(
        playing: playerState.playing,
        // Every state from the audio player gets mapped onto an audio_service state.
        *//*processingState: {
          ProcessingState.none: AudioProcessingState.none,
          ProcessingState.loading: AudioProcessingState.connecting,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[playerState.processingState],*//*
        // Tell clients what buttons/controls should be enabled in the
        // current state.
        controls: [
          playerState.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
      );
    });*/
    // Play when ready.
    audioPlayer.play(url);
    // Start loading something (will play when ready).
    await audioPlayer.setUrl(mediaItem.id);
  }
}
