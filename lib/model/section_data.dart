// To parse this JSON data, do
//
//     final sectionData = sectionDataFromJson(jsonString);

import 'dart:convert';

SectionData sectionDataFromJson(String str) => SectionData.fromJson(json.decode(str));

String sectionDataToJson(SectionData data) => json.encode(data.toJson());

class SectionData {
  SectionData({
    this.code,
    this.status,
    this.message,
    this.data,
  });

  int code;
  String status;
  String message;
  Data data;

  factory SectionData.fromJson(Map<String, dynamic> json) => SectionData(
    code: json["code"],
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.banner,
    this.about,
    this.galleries,
    this.teams,
    this.blogs,
    this.schedules,
    this.videoPlaylist,
    this.contactDetails,
    this.socialIcons,
    this.footer,
    this.channelData,
    this.notifications,
  });

  List<Banner> banner;
  About about;
  List<Gallery> galleries;
  List<Team> teams;
  List<Blog> blogs;
  List<Schedule> schedules;
  List<VideoPlaylist> videoPlaylist;
  List<ContactDetail> contactDetails;
  List<ContactDetail> socialIcons;
  List<Footer> footer;
  List<ChannelDatum> channelData;
  List<Notification> notifications;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    banner: List<Banner>.from(json["banner"].map((x) => Banner.fromJson(x))),
    about: About.fromJson(json["about"]),
    galleries: List<Gallery>.from(json["galleries"].map((x) => Gallery.fromJson(x))),
    teams: List<Team>.from(json["teams"].map((x) => Team.fromJson(x))),
    blogs: List<Blog>.from(json["blogs"].map((x) => Blog.fromJson(x))),
    schedules: List<Schedule>.from(json["schedules"].map((x) => Schedule.fromJson(x))),
    videoPlaylist: List<VideoPlaylist>.from(json["video_playlist"].map((x) => VideoPlaylist.fromJson(x))),
    contactDetails: List<ContactDetail>.from(json["contact_details"].map((x) => ContactDetail.fromJson(x))),
    socialIcons: List<ContactDetail>.from(json["social_icons"].map((x) => ContactDetail.fromJson(x))),
    footer: List<Footer>.from(json["footer"].map((x) => Footer.fromJson(x))),
    channelData: List<ChannelDatum>.from(json["channel_data"].map((x) => ChannelDatum.fromJson(x))),
    notifications: List<Notification>.from(json["notifications"].map((x) => Notification.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "banner": List<dynamic>.from(banner.map((x) => x.toJson())),
    "about": about.toJson(),
    "galleries": List<dynamic>.from(galleries.map((x) => x.toJson())),
    "teams": List<dynamic>.from(teams.map((x) => x.toJson())),
    "blogs": List<dynamic>.from(blogs.map((x) => x.toJson())),
    "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
    "video_playlist": List<dynamic>.from(videoPlaylist.map((x) => x.toJson())),
    "contact_details": List<dynamic>.from(contactDetails.map((x) => x.toJson())),
    "social_icons": List<dynamic>.from(socialIcons.map((x) => x.toJson())),
    "footer": List<dynamic>.from(footer.map((x) => x.toJson())),
    "channel_data": List<dynamic>.from(channelData.map((x) => x.toJson())),
    "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
  };
}

class About {
  About({
    this.id,
    this.title,
    this.time,
    this.description,
    this.image,
  });

  int id;
  String title;
  String time;
  String description;
  String image;

  factory About.fromJson(Map<String, dynamic> json) => About(
    id: json["id"],
    title: json["title"],
    time: json["time"],
    description: json["description"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "time": time,
    "description": description,
    "image": image,
  };
}

class Banner {
  Banner({
    this.id,
    this.heading,
    this.subtitle,
    this.btnName,
    this.btnUrl,
    this.image,
  });

  int id;
  String heading;
  String subtitle;
  String btnName;
  String btnUrl;
  String image;

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    id: json["id"],
    heading: json["heading"],
    subtitle: json["subtitle"],
    btnName: json["btn_name"],
    btnUrl: json["btn_url"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "heading": heading,
    "subtitle": subtitle,
    "btn_name": btnName,
    "btn_url": btnUrl,
    "image": image,
  };
}

class Blog {
  Blog({
    this.id,
    this.title,
    this.details,
    this.thumbImage,
    this.createdAt,
  });

  int id;
  String title;
  String details;
  String thumbImage;
  String createdAt;

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
    id: json["id"],
    title: json["title"],
    details: json["details"],
    thumbImage: json["thumb_image"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "details": details,
    "thumb_image": thumbImage,
    "created_at": createdAt,
  };
}

class ChannelDatum {
  ChannelDatum({
    this.channelName,
    this.description,
    this.radioUrl,
    this.channelLogo,
  });

  String channelName;
  String description;
  String radioUrl;
  String channelLogo;

  factory ChannelDatum.fromJson(Map<String, dynamic> json) => ChannelDatum(
    channelName: json["channel_name"],
    description: json["description"],
    radioUrl: json["radio_url"],
    channelLogo: json["channel_logo"],
  );

  Map<String, dynamic> toJson() => {
    "channel_name": channelName,
    "description": description,
    "radio_url": radioUrl,
    "channel_logo": channelLogo,
  };
}

class ContactDetail {
  ContactDetail({
    this.id,
    this.title,
    this.details,
    this.icon,
    this.url,
  });

  int id;
  String title;
  String details;
  String icon;
  String url;

  factory ContactDetail.fromJson(Map<String, dynamic> json) => ContactDetail(
    id: json["id"],
    title: json["title"],
    details: json["details"] == null ? null : json["details"],
    icon: json["icon"],
    url: json["url"] == null ? null : json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "details": details == null ? null : details,
    "icon": icon,
    "url": url == null ? null : url,
  };
}

class Footer {
  Footer({
    this.contactHeading,
    this.contactSubtitle,
    this.appHeading,
    this.appSubtitle,
    this.playstoreLink,
    this.applestoreLink,
  });

  String contactHeading;
  String contactSubtitle;
  String appHeading;
  String appSubtitle;
  String playstoreLink;
  String applestoreLink;

  factory Footer.fromJson(Map<String, dynamic> json) => Footer(
    contactHeading: json["contact_heading"],
    contactSubtitle: json["contact_subtitle"],
    appHeading: json["app_heading"],
    appSubtitle: json["app_subtitle"],
    playstoreLink: json["playstore_link"],
    applestoreLink: json["applestore_link"],
  );

  Map<String, dynamic> toJson() => {
    "contact_heading": contactHeading,
    "contact_subtitle": contactSubtitle,
    "app_heading": appHeading,
    "app_subtitle": appSubtitle,
    "playstore_link": playstoreLink,
    "applestore_link": applestoreLink,
  };
}

class Gallery {
  Gallery({
    this.id,
    this.image,
  });

  int id;
  String image;

  factory Gallery.fromJson(Map<String, dynamic> json) => Gallery(
    id: json["id"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
  };
}

class Notification {
  Notification({
    this.title,
    this.description,
    this.date,
    this.time,
  });

  String title;
  String description;
  String date;
  String time;

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    title: json["title"],
    description: json["description"],
    date: json["date"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "date": date,
    "time": time,
  };
}

class Schedule {
  Schedule({
    this.saturday,
    this.sunday,
    this.monday,
  });

  Day saturday;
  Day sunday;
  Day monday;

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    saturday: json["Saturday"] == null ? null : Day.fromJson(json["Saturday"]),
    sunday: json["Sunday"] == null ? null : Day.fromJson(json["Sunday"]),
    monday: json["Monday"] == null ? null : Day.fromJson(json["Monday"]),
  );

  Map<String, dynamic> toJson() => {
    "Saturday": saturday == null ? null : saturday.toJson(),
    "Sunday": sunday == null ? null : sunday.toJson(),
    "Monday": monday == null ? null : monday.toJson(),
  };
}

class Day {
  Day({
    this.id,
    this.dayId,
    this.teamId,
    this.name,
    this.time,
    this.image,
    this.teamImage,
  });

  int id;
  int dayId;
  int teamId;
  String name;
  String time;
  String image;
  String teamImage;

  factory Day.fromJson(Map<String, dynamic> json) => Day(
    id: json["id"],
    dayId: json["day_id"],
    teamId: json["team_id"],
    name: json["name"],
    time: json["time"],
    image: json["image"],
    teamImage: json["team_image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day_id": dayId,
    "team_id": teamId,
    "name": name,
    "time": time,
    "image": image,
    "team_image": teamImage,
  };
}

class Team {
  Team({
    this.id,
    this.name,
    this.designation,
    this.image,
  });

  int id;
  String name;
  String designation;
  String image;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json["id"],
    name: json["name"],
    designation: json["designation"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "designation": designation,
    "image": image,
  };
}

class VideoPlaylist {
  VideoPlaylist({
    this.id,
    this.heading,
    this.subtitle,
    this.videoUrl,
    this.image,
  });

  int id;
  String heading;
  String subtitle;
  String videoUrl;
  String image;

  factory VideoPlaylist.fromJson(Map<String, dynamic> json) => VideoPlaylist(
    id: json["id"],
    heading: json["heading"],
    subtitle: json["subtitle"],
    videoUrl: json["video_url"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "heading": heading,
    "subtitle": subtitle,
    "video_url": videoUrl,
    "image": image,
  };
}
