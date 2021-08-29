import 'package:audio_service/audio_service.dart';
import 'package:croydoncentralradio/utils/strings.dart';

class RadioLibrary {

  var jsonResponse;

  final _items = <MediaItem>[
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl1,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName1,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo1,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl2,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName2,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo2,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl3,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName3,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo3,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl4,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName4,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo4,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl5,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName5,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo5,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl6,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName6,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo6,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl7,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName7,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo7,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl8,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName8,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo8,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl9,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName9,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo9,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl10,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName10,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo10,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl11,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName11,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo11,
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: Strings.radioUrl12,
      album: "CROYDON CENTRAL RADIO",
      title: Strings.channelName12,
      artist: "CROYDON CENTRAL RADIO",
      duration: Duration(milliseconds: 0),
      artUri: Strings.channelLogo12,
    ),
  ];

  List<MediaItem> get items => _items;
}