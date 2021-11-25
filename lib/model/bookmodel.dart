import 'dart:convert';

import 'dart:io';

class BookModel {
  BookModel({
    required this.id,
    required this.image,
    required this.title,
    required this.pages,
    required this.year,
    required this.size,
    required this.ifNew,
    required this.downloads,
    required this.linkToInfo,


  });
  late final String id;
  late final String image;
  late final String title;
  late final String pages;
  late final String year;
  late final String size;
  late final String ifNew;
  late final String downloads;
  late final String linkToInfo;

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    id: json["id"],
    image: json["image"],
    title: json["title"],
    pages: json["pages"],
    year: json["year"],
    size: json["size"],
    ifNew: json["ifNew"],
    downloads: json["downloads"],
    linkToInfo: json["linkToInfo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "title": title,
    "pages": pages,
    "year": year,
    "size": size,
    "ifNew": ifNew,
    "downloads": downloads,
    "linkToInfo": linkToInfo,
  };
}

List<BookFSD> BookFSDFromJson(String str) =>
    List<BookFSD>.from(json.decode(str).map((x) => BookFSD.fromJson(x)));

String BookFSDToJson(List<BookFSD> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BookFSD {

  BookFSD({
    required this.title,
    required this.taskId,
    required this.bookCoverImage,
    required this.fileName,
  });


  String title;
  String taskId;
  String bookCoverImage;
  String fileName;

  factory BookFSD.fromJson(Map<String, dynamic> json) => BookFSD(
    title: json["title"],
    taskId: json["taskId"],
    bookCoverImage: json["bookCoverImage"],
    fileName: json["fileName"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "taskId": taskId,
    "bookCoverImage": bookCoverImage,
    "fileName": fileName,
  };


}

class BookDA {

  BookDA({
    required this.bookDetails,
    required this.file,
  });


  BookFSD bookDetails;
  File file;

  // factory BookFSD.fromJson(Map<String, dynamic> json) => BookFSD(
  //   title: json["title"],
  //   taskId: json["taskId"],
  //   bookCoverImage: json["bookCoverImage"],
  //   fileName: json["fileName"],
  // );
  //
  // Map<String, dynamic> toJson() => {
  //   "title": title,
  //   "taskId": taskId,
  //   "bookCoverImage": bookCoverImage,
  //   "fileName": fileName,
  // };


}
