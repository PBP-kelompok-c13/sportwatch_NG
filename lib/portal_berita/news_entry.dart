// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

NewsEntry newsEntryFromJson(String str) => NewsEntry.fromJson(json.decode(str));

String newsEntryToJson(NewsEntry data) => json.encode(data.toJson());

class ReactionSummary {
  String key;
  String label;
  String emoji;
  int count;

  ReactionSummary({
    required this.key,
    required this.label,
    required this.emoji,
    required this.count,
  });

  factory ReactionSummary.fromJson(Map<String, dynamic> json) =>
      ReactionSummary(
        key: json["key"],
        label: json["label"],
        emoji: json["emoji"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
    "key": key,
    "label": label,
    "emoji": emoji,
    "count": count,
  };
}

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
  List<ReactionSummary> reactionSummary;
  String? userReaction;

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
    required this.reactionSummary,
    this.userReaction,
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
    reactionSummary: json["reaction_summary"] == null
        ? []
        : List<ReactionSummary>.from(
            json["reaction_summary"].map((x) => ReactionSummary.fromJson(x)),
          ),
    userReaction: json["user_reaction"],
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
    "reaction_summary": List<dynamic>.from(
      reactionSummary.map((x) => x.toJson()),
    ),
    "user_reaction": userReaction,
  };
}
