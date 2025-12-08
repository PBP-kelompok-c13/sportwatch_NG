class NewsComment {
  int id;
  String user;
  String content;
  String createdAt;

  NewsComment({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory NewsComment.fromJson(Map<String, dynamic> json) => NewsComment(
    id: json["id"],
    user: json["user"],
    content: json["content"],
    createdAt: json["created_at"],
  );
}
