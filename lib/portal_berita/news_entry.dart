// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

NewsEntry newsEntryFromJson(String str) => NewsEntry.fromJson(json.decode(str));

String newsEntryToJson(NewsEntry data) => json.encode(data.toJson());

class NewsEntry {
  String id;
  String judul;
  String konten;
  String kategori;
  String thumbnail;
  int views;
  dynamic penulis;
  String sumber;
  bool isPublished;
  DateTime tanggalDibuat;
  DateTime tanggalDiperbarui;

  NewsEntry({
    required this.id,
    required this.judul,
    required this.konten,
    required this.kategori,
    required this.thumbnail,
    required this.views,
    required this.penulis,
    required this.sumber,
    required this.isPublished,
    required this.tanggalDibuat,
    required this.tanggalDiperbarui,
  });

  factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
        id: json["id"],
        judul: json["judul"],
        konten: json["konten"],
        kategori: json["kategori"],
        thumbnail: json["thumbnail"],
        views: json["views"],
        penulis: json["penulis"],
        sumber: json["sumber"],
        isPublished: json["is_published"],
        tanggalDibuat: DateTime.parse(json["tanggal_dibuat"]),
        tanggalDiperbarui: DateTime.parse(json["tanggal_diperbarui"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "konten": konten,
        "kategori": kategori,
        "thumbnail": thumbnail,
        "views": views,
        "penulis": penulis,
        "sumber": sumber,
        "is_published": isPublished,
        "tanggal_dibuat": tanggalDibuat.toIso8601String(),
        "tanggal_diperbarui": tanggalDiperbarui.toIso8601String(),
      };
}
