import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app_review/app_review.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:croydoncentralradio/class/custom_loading.dart';
import 'package:croydoncentralradio/class/url_launcher.dart';
import 'package:croydoncentralradio/model/radio_library.dart';
import 'package:croydoncentralradio/model/section_data.dart';
import 'package:croydoncentralradio/screens/notifications_screen.dart';
import 'package:croydoncentralradio/urls/endpoints.dart';
import 'package:croydoncentralradio/urls/urls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:phone_state_i/phone_state_i.dart';
import 'package:croydoncentralradio/utils/custom_color.dart';
import 'package:croydoncentralradio/utils/strings.dart';
import 'package:rxdart/rxdart.dart';

import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:volume_control/volume_control.dart';

import 'About_Us.dart';
import 'All_Radio_Station.dart';
import 'BottomPanel.dart';
import 'Helper/Constant.dart';
import 'Helper/Favourite_Helper.dart';
import 'Helper/Model.dart';
import 'Now_Playing.dart';
import 'package:just_audio/just_audio.dart';

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
        child: AudioServiceWidget(
          child: MyHomePage(),
        ),
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

List<MediaItem> myRadioList;
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

  //for volume slider
  double _val = 0.5;
  Timer timer;

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

    myRadioList = List();
    _getSectionData();
    initVolumeState();
    isSearching = false;
    panelController = PanelController();
    // Initialize the Tab Controller
    tabController = TabController(length: 1, vsync: this);
    // firebaseCloudMessaging_Listeners();

    tempSongList.clear();
    radioList.clear();

    // getRadioStation();
    loading = false;
    // initAudioPlayer();

    // AudioPlayer.logEnabled = false;

    firNotInitialize();

    handlePhoneCall();

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

    // playerState = PlayerState.stopped;
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

  Future<void> initVolumeState() async {
    if (!mounted) return;

    //read the current volume
    _val = await VolumeControl.volume;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(25.0),
      topRight: Radius.circular(25.0),
    );

    return WillPopScope(
        onWillPop: _backPressed,
        child: Scaffold(
            key: _globalKey,
            appBar: getAppbar(),
            drawer: getDrawer(),
            backgroundColor: CustomColor.primaryColor,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: AudioService.runningStream,
                builder: (context, snapshot) {
                  final running = snapshot.data ?? false;
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      if (!running) ...[
                        // UI to show when we're not running, i.e. a menu.
                        FutureBuilder<SectionData>(
                          future: _getSectionData(),
                          builder: (context, snapshot) {
                            if(snapshot.hasData) {
                              final radio = snapshot.data.data.channelData;
                              return ListView.builder(
                                itemCount: radio.length,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Card(
                                        elevation: 5.0,
                                        child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                    padding: EdgeInsets.all(5.0),
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(5),
                                                        child: FadeInImage(
                                                          placeholder: AssetImage(
                                                            'assets/image/default_image.png',
                                                          ),
                                                          image: NetworkImage(
                                                            radio[index].channelLogo,
                                                          ),
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                        ))),
                                                Expanded(
                                                    child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(
                                                              radio[index].channelName,
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .subhead
                                                                  .copyWith(fontWeight: FontWeight.bold),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              // dense: true,
                                                            ),
                                                            Text(
                                                              radio[index].description,
                                                              style: Theme.of(context).textTheme.caption,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              // dense: true,
                                                            ),
                                                          ],
                                                        ))),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.play_arrow,
                                                      size: 40,
                                                      color: primary,
                                                    ),
                                                    onPressed: null),
                                              ],
                                            ))),
                                    onTap: () {
                                      setState(() {
                                        tapIndex = index;
                                        print(tapIndex);
                                        _play();
                                      });

                                    },
                                  );
                                },
                              );
                            }
                            return CustomLoading();
                          },
                        )
                        // if (kIsWeb || !Platform.isMacOS) textToSpeechButton(),
                      ] else ...[
                        // UI to show when we're running, i.e. player state/controls.

                        // Queue display/controls.
                        // StreamBuilder<QueueState>(
                        //   stream: _queueStateStream,
                        //   builder: (context, snapshot) {
                        //     final queueState = snapshot.data;
                        //     final queue = queueState?.queue ?? [];
                        //     final mediaItem = queueState?.mediaItem;
                        //     return Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         if (queue.isNotEmpty)
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               IconButton(
                        //                 icon: Icon(Icons.skip_previous),
                        //                 iconSize: 64.0,
                        //                 onPressed: mediaItem == queue.first
                        //                     ? null
                        //                     : AudioService.skipToPrevious,
                        //               ),
                        //               IconButton(
                        //                 icon: Icon(Icons.skip_next),
                        //                 iconSize: 64.0,
                        //                 onPressed: mediaItem == queue.last
                        //                     ? null
                        //                     : AudioService.skipToNext,
                        //               ),
                        //             ],
                        //           ),
                        //         if (mediaItem?.title != null) Column(
                        //           children: [
                        //             Text(mediaItem.title),
                        //
                        //           ],
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // ),
                        // Play/pause/stop buttons.
                        // StreamBuilder<bool>(
                        //   stream: AudioService.playbackStateStream
                        //       .map((state) => state.playing)
                        //       .distinct(),
                        //   builder: (context, snapshot) {
                        //     final playing = snapshot.data ?? false;
                        //     return Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         if (playing) pauseButton() else playButton(),
                        //         stopButton(),
                        //       ],
                        //     );
                        //   },
                        // ),

                        StreamBuilder<QueueState>(
                          stream: _queueStateStream,
                          builder: (context, snapshot) {
                            final queueState = snapshot.data;
                            final queue = queueState?.queue ?? [];
                            final mediaItem = queueState?.mediaItem;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (mediaItem?.title != null) Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10
                                      ),
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * .35,
                                        child: Center(
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: FadeInImage(
                                                placeholder: AssetImage(
                                                    'assets/image/default_image.png'
                                                ),
                                                image: NetworkImage(mediaItem.artUri),
                                                width: MediaQuery.of(context).size.width,
                                                height: MediaQuery.of(context).size.height * .35,
                                                fit: BoxFit.fitWidth,
                                              )),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      mediaItem.title,
                                      style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    StreamBuilder<bool>(
                                        stream: AudioService.playbackStateStream
                                            .map((state) => state.playing)
                                            .distinct(),
                                      builder: (context, snapshot) {
                                        final playing = snapshot.data ?? false;
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              stopButton()
                                            ],
                                          );
                                      },
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8.0),
                                    //   child: Text(
                                    //     curPlayList[curPos].description,
                                    //     style: Theme.of(context)
                                    //         .textTheme
                                    //         .subtitle
                                    //         .copyWith(color: Colors.white54),
                                    //     textAlign: TextAlign.center,
                                    //   ),
                                    // ),
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
                                ) else CustomLoading(),
                                if (queue.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                            Icons.skip_previous,
                                          color: Colors.white,
                                        ),
                                        iconSize: 50.0,
                                        onPressed: mediaItem == queue.first
                                            ? null
                                            : AudioService.skipToPrevious,
                                      ),
                                      StreamBuilder<bool>(
                                        stream: AudioService.playbackStateStream
                                            .map((state) => state.playing)
                                            .distinct(),
                                        builder: (context, snapshot) {
                                          final playing = snapshot.data ?? false;
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (playing) pauseButton() else playButton(),
                                              // stopButton(),
                                            ],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.skip_next,
                                          color: Colors.white,
                                        ),
                                        iconSize: 50.0,
                                        onPressed: mediaItem == queue.last
                                            ? null
                                            : AudioService.skipToNext,
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                        // A seek bar.
                        // StreamBuilder<MediaState>(
                        //   stream: _mediaStateStream,
                        //   builder: (context, snapshot) {
                        //     final mediaState = snapshot.data;
                        //     return SeekBar(
                        //       duration:
                        //       mediaState?.mediaItem?.duration ?? Duration.zero,
                        //       position: mediaState?.position ?? Duration.zero,
                        //       onChangeEnd: (newPosition) {
                        //         AudioService.seekTo(newPosition);
                        //       },
                        //     );
                        //   },
                        // ),
                        // Display the processing state.
                        // StreamBuilder<AudioProcessingState>(
                        //   stream: AudioService.playbackStateStream
                        //       .map((state) => state.processingState)
                        //       .distinct(),
                        //   builder: (context, snapshot) {
                        //     final processingState =
                        //         snapshot.data ?? AudioProcessingState.none;
                        //     return Text(
                        //         "Processing state: ${describeEnum(processingState)}");
                        //   },
                        // ),
                        // // Display the latest custom event.
                        // StreamBuilder(
                        //   stream: AudioService.customEventStream,
                        //   builder: (context, snapshot) {
                        //     return Text("custom event: ${snapshot.data}");
                        //   },
                        // ),
                        // // Display the notification click status.
                        // StreamBuilder<bool>(
                        //   stream: AudioService.notificationClickEventStream,
                        //   builder: (context, snapshot) {
                        //     return Text(
                        //       'Notification Click Status: ${snapshot.data}',
                        //     );
                        //   },
                        // ),

                      ],
                    ],
                  );
                },
              ),
            )
        )
    );
  }

  Future<SectionData> _getSectionData () async {
    Uri url = Uri.parse('${Urls.mainUrl}${Endpoints.sectionData}');

    final response = await http.get(url);
    var data = jsonDecode(response.body);
    List list = data['data']['channel_data'];
    // print('response data: '+ data.toString());
    // for(int i = 0; i < list.length; i++ ) {
    //   setState(() {
    //     myRadioList.add(MediaItem(
    //       id: list[i]['channel_name'],
    //       album: "CROYDON CENTRAL RADIO",
    //       title: list[i]['radio_url'],
    //       artist: "CROYDON CENTRAL RADIO",
    //       duration: Duration(milliseconds: 0),
    //       artUri: list[i]['channel_logo'],
    //     ));
    //     // print('new length: '+myRadioList.length.toString());
    //   });
    // }
    setState(() {


      Strings.channelName1 = list[0]['channel_name'];
      Strings.radioUrl1 = list[0]['radio_url'];
      Strings.channelLogo1 = list[0]['channel_logo'];

      Strings.channelName2 = list[1]['channel_name'];
      Strings.radioUrl2 = list[1]['radio_url'];
      Strings.channelLogo2 = list[1]['channel_logo'];

      Strings.channelName3 = list[2]['channel_name'];
      Strings.radioUrl3 = list[2]['radio_url'];
      Strings.channelLogo3 = list[2]['channel_logo'];


      Strings.channelName4 = list[3]['channel_name'];
      Strings.radioUrl4 = list[3]['radio_url'];
      Strings.channelLogo4 = list[3]['channel_logo'];

      Strings.channelName5 = list[4]['channel_name'];
      Strings.radioUrl5 = list[4]['radio_url'];
      Strings.channelLogo5 = list[4]['channel_logo'];

      Strings.channelName6 = list[5]['channel_name'];
      Strings.radioUrl6 = list[5]['radio_url'];
      Strings.channelLogo6 = list[5]['channel_logo'];


      Strings.channelName7 = list[6]['channel_name'];
      Strings.radioUrl7 = list[6]['radio_url'];
      Strings.channelLogo7 = list[6]['channel_logo'];

      Strings.channelName8 = list[7]['channel_name'];
      Strings.radioUrl8 = list[7]['radio_url'];
      Strings.channelLogo8 = list[7]['channel_logo'];

      Strings.channelName9 = list[8]['channel_name'];
      Strings.radioUrl9 = list[8]['radio_url'];
      Strings.channelLogo9 = list[8]['channel_logo'];


      Strings.channelName10 = list[9]['channel_name'];
      Strings.radioUrl10 = list[9]['radio_url'];
      Strings.channelLogo10 = list[9]['channel_logo'];

      Strings.channelName11 = list[10]['channel_name'];
      Strings.radioUrl11 = list[10]['radio_url'];
      Strings.channelLogo11 = list[10]['channel_logo'];

      Strings.channelName12 = list[11]['channel_name'];
      Strings.radioUrl12 = list[11]['radio_url'];
      Strings.channelLogo12 = list[11]['channel_logo'];

      // myRadioList = list;
      print('list data: '+ list[0]['channel_name'].toString());
    });

    return SectionData.fromJson(data);
  }

  IconButton playButton() => IconButton(
    icon: Icon(Icons.play_arrow,
      color: Colors.white,
    ),
    iconSize: 64.0,
    onPressed: AudioService.play,
  );

  IconButton pauseButton() => IconButton(
    icon: Icon(
        Icons.pause,
      color: Colors.white,
    ),
    iconSize: 50.0,
    onPressed: AudioService.pause,
  );

  IconButton stopButton() => IconButton(
    icon: Icon(
        Icons.list,
      color: Colors.white,
    ),
    iconSize: 50.0,
    onPressed: AudioService.stop,
  );

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
              (mediaItem, position) => MediaState(mediaItem, position));

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
              (queue, mediaItem) => QueueState(queue, mediaItem));

  Future<bool> _backPressed() async {
    return (await showDialog(
      barrierColor: Colors.white,
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Alert!',
          style: TextStyle(
              color: Colors.red
          ),
        ),
        content: Text(
          'Do you want to exit ${Strings.appName}?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () {
              AudioService.stop();
              SystemNavigator.pop();
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
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

  // void initAudioPlayer() {
  //
  //   audioPlayer = AudioPlayer(mode: mode);
  //
  //   durationSubscription = audioPlayer.onDurationChanged.listen((duration1) {
  //     //print("duration change***$duration1");
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() => duration = duration1);
  //
  //     // if (Theme.of(context).platform == TargetPlatform.iOS) {
  //     if (Platform.isIOS) {
  //       // set atleast title to see the notification bar on ios.
  //       audioPlayer.startHeadlessService();
  //
  //       audioPlayer.setNotification(
  //           title: '$appname',
  //           artist: '${curPlayList[curPos].description}',
  //           //albumTitle: '${curPlayList[curPos].cat_name}',
  //           imageUrl: '${curPlayList[curPos].channelLogo}',
  //           forwardSkipInterval: const Duration(seconds: 30),
  //           // default is 30s
  //           backwardSkipInterval: const Duration(seconds: 30),
  //           // default is 30s
  //           duration: duration1,
  //           elapsedTime: Duration(seconds: 0));
  //     }
  //   });
  //
  //   positionSubscription =
  //       audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
  //         position = p;
  //       }));
  //
  //   playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((event) {
  //     _next();
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       position = duration;
  //     });
  //   });
  //
  //   playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
  //     // print('audioPlayer error : $msg');
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       playerState = PlayerState.stopped;
  //       duration = Duration(seconds: 0);
  //       position = Duration(seconds: 0);
  //     });
  //   });
  //
  //   audioPlayer.onPlayerStateChanged.listen((state) {
  //     // print('audioPlayer state : $state');
  //
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       audioPlayerState = state;
  //     });
  //   });
  //   //  AudioPlayer.logEnabled = true;
  //   audioPlayer.onNotificationPlayerStateChanged.listen((state) {
  //     if (!mounted) return;
  //     setState(() => audioPlayerState = state);
  //   });
  // }

  void _next() async {

    // curPos = curPos + 1;
    // if (curPos < curPlayList.length) {
    //   final result = await audioPlayer.pause();
    //   if (result == 1) setState(() => playerState = PlayerState.paused);
    //
    //   position = null;
    //   duration = null;
    //   url = curPlayList[curPos].radioUrl;
    //   _play();
    // } else {
    //   curPos = curPos - 1;
    // }
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
    AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Service Notifications',
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      androidNotificationColor: 0xFF1c0707,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
    );

    // final playPosition = (position != null &&
    //     duration != null &&
    //     position.inMilliseconds > 0 &&
    //     position.inMilliseconds < duration.inMilliseconds)
    //     ? position
    //     : null;
    //
    // print("play current**$url");
    // final result =
    // await audioPlayer.play(url, isLocal: isLocal, position: playPosition);
    // if (!mounted) {
    //   return;
    // }
    // if (result == 1) {
    //   setState(() {
    //     playerState = PlayerState.playing;
    //   });
    // }
    //
    // if (Platform.isIOS) {
    //   await audioPlayer.setPlaybackRate(playbackRate: 1.0);
    // }
  }

  void _pause() async {

    // if(Platform.isIOS){
    //   final result = await audioPlayer.pause();
    //   if (result == 1) {
    //     setState(() => playerState = PlayerState.paused);
    //   }
    // }else {
    //   if (duration != null) {
    //     final result = await audioPlayer.pause();
    //     if (result == 1) {
    //       setState(() => playerState = PlayerState.paused);
    //     }
    //   }
    // }
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
              Image.network(
                Strings.channelLogo1,
                width: MediaQuery.of(context).size.width,
                height: 200,
              ),
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
              ListTile(
                  leading: Icon(
                      FontAwesomeIcons.chrome,
                      color: Colors.white
                  ),
                  title: Text(
                    'Website',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncher.url(Strings.webUrl);
                  }),
            ],
          )),
    );
  }

}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {


  final _mediaLibrary = RadioLibrary();


  AudioPlayer _player = new AudioPlayer();
  AudioProcessingState _skipState;
  Seeker _seeker;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> get queue => _mediaLibrary.items;
  // List<MediaItem> get queue => myRadioList;

  int get index => _player.currentIndex;
  MediaItem get mediaItem => index == null ? null : queue[index];

  @override
  Future<void> onStart(Map<String, dynamic> params) async {

    // We configure the audio session for speech since we're playing a podcast.
    // You can also put this in your app's initialisation if your app doesn't
    // switch between two types of audio as this example does.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
        // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
        // If we just came from skipping between tracks, clear the skip
        // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.setAudioSource(ConcatenatingAudioSource(
        children:
        queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ));
      // In this example, we automatically start playing on start.
      onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    _player.seek(Duration.zero, index: newIndex);
    // Demonstrate custom events.
    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem)
        ..start();
    }
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

// class MediaLibrary {
//
//   var jsonResponse;
//
//   final _items = <MediaItem>[
//     MediaItem(
//       // This can be any unique id, but we use the audio URL for convenience.
//       id: "https://croydoncentralradio.com/radio/8130/radio.mp3",
//       album: "CROYDON CENTRAL RADIO",
//       title: 'CROYDON CENTRAL RADIO Gangster',
//       artist: "CROYDON CENTRAL RADIO",
//       duration: Duration(milliseconds: 0),
//       artUri: "https://radio.appdevs.net/power-up/assets/admin/images/611d1911ed2bc1629296913.jpeg",
//     ),
//     MediaItem(
//       id: "https://croydoncentralradio.com/radio/8060/radio.mp3",
//       album: "CROYDON CENTRAL RADIO",
//       title: "CROYDON CENTRAL RADIO Raw",
//       artist: "CROYDON CENTRAL RADIO",
//       duration: Duration(milliseconds: 0),
//       artUri: "https://radio.appdevs.net/power-up/assets/admin/images/611d1911ed2bc1629296913.jpeg",
//     ),
//   ];
//
//   List<MediaItem> get items => _items;
// }

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    this.duration,
    this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final value = min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
        widget.duration.inMilliseconds.toDouble());
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: (value) {
            if (!_dragging) {
              _dragging = true;
            }
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));
            }
            _dragging = false;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                  .firstMatch("$_remaining")
                  ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
      this.player,
      this.positionInterval,
      this.stepInterval,
      this.mediaItem,
      );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
