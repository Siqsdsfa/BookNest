import 'dart:convert';

BookInfo userInfoFromJson(String str) => BookInfo.fromJson(json.decode(str));

String userInfoToJson(BookInfo data) => json.encode(data.toJson());

class BookInfo {
  String title;
  String writer;
  String description;
  String publishDate;
  String imageURL;
  String uploadedBy;
  String docID;
  int likes;
  List<dynamic> usersLikes;
  int dislikes;
  List usersDislikes;

  BookInfo({
    required this.title,
    required this.writer,
    required this.description,
    required this.publishDate,
    required this.imageURL,
    required this.uploadedBy,
    required this.docID,
    required this.likes,
    required this.dislikes,
    required this.usersLikes,
    required this.usersDislikes,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) => BookInfo(
        title: json["title"],
        writer: json["writer"],
        description: json["description"],
        publishDate: json["publishDate"],
        imageURL: json["imageURL"],
        uploadedBy: json["uploadedBy"],
        docID: json["docID"],
        likes: json["likes"],
        dislikes: json["dislikes"],
        usersLikes: json["usersLikes"],
        usersDislikes: json["usersDislikes"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "writer": writer,
        "description": description,
        "publishDate": publishDate,
        "imageURL": imageURL,
        "uploadedBy": uploadedBy,
        "docID": docID,
        "likes": likes,
        "dislikes": dislikes,
        "usersLikes": usersLikes,
        "usersDislikes": usersDislikes,
      };
}
