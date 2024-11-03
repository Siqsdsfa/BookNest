import 'dart:convert';

BookInfo userInfoFromJson(String str) =>
    BookInfo.fromJson(json.decode(str));

String userInfoToJson(BookInfo data) => json.encode(data.toJson());

class BookInfo {
  String title;
  String autor;
  String description;
  String publishDate;
  String imageURL;
  String uploadedBy;
  String docID;

  BookInfo({
    required this.title,
    required this.autor,
    required this.description,
    required this.publishDate,
    required this.imageURL,
    required this.uploadedBy,
    required this.docID,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) =>
      BookInfo(
        title: json["title"],
        autor: json["autor"],
        description: json["description"],
        publishDate: json["publishDate"],
        imageURL: json["imageURL"],
        uploadedBy: json["uploadedBy"],
        docID: json["docID"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "autor": autor,
        "description": description,
        "publishDate": publishDate,
        "imageURL": imageURL,
        "uploadedBy": uploadedBy,
        "docID": docID,
      };
}
