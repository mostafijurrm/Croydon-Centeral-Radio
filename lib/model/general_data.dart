// To parse this JSON data, do
//
//     final generalData = generalDataFromJson(jsonString);

import 'dart:convert';

GeneralData generalDataFromJson(String str) => GeneralData.fromJson(json.decode(str));

String generalDataToJson(GeneralData data) => json.encode(data.toJson());

class GeneralData {
  GeneralData({
    this.code,
    this.status,
    this.message,
    this.data,
  });

  int code;
  String status;
  String message;
  Data data;

  factory GeneralData.fromJson(Map<String, dynamic> json) => GeneralData(
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
    this.liveUrl,
    this.icon,
    this.sitename,
  });

  String liveUrl;
  String icon;
  String sitename;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    liveUrl: json["live_url"],
    icon: json["icon"],
    sitename: json["sitename"],
  );

  Map<String, dynamic> toJson() => {
    "live_url": liveUrl,
    "icon": icon,
    "sitename": sitename,
  };
}
