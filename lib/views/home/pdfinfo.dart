import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signup_signin/model/bookmodel.dart';
import 'package:signup_signin/services/prefs/prefs.dart';
import 'package:signup_signin/views/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import "dart:io";
import 'package:signup_signin/views/home/pdf.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

class InfoView extends StatefulWidget {
  const InfoView({Key? key, required this.book}) : super(key: key);
  final BookModel book;

  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  bool animateOpacity = false;
  @override
  void initState() {
    super.initState();
  }


  Future<BookInfo?> getContents() async {
      BookInfo bookInfo = BookInfo(bookAuthorMain: '', suggestedBooks: []) ;
       String url = 'https://bookish.herokuapp.com/api/bookishInfo.php?bookinfolink=${widget.book.linkToInfo}&getbookpdf=false';
       Response response = await http.get(Uri.parse(url));
       print(response);
       if(response.statusCode == 200){
         final bookInfo = bookInfoFromJson(response.body);
         print(bookInfo.bookAuthorMain);
         return bookInfo;
       }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getContents(),
        builder: (BuildContext context, AsyncSnapshot<BookInfo?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SafeArea(child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                    onTap: (){
                      Navigator.pop(context);

                    },
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
                backgroundColor: Colors.black,
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Container(
                                  height: 160,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 6.0,
                                          offset: Offset(0.0, 0.5)
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: ClipRRect(
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3),  ),
                                              child: Image.network(widget.book.image.trim(), fit: BoxFit.fill,))
                                      ),
                                      const SizedBox(width: 3,),
                                      Expanded(
                                          flex: 8,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(widget.book.title, style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 3, overflow: TextOverflow.clip, textAlign: TextAlign.justify),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(widget.book.pages.trim() ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 11)),
                                                  const Text('.'),
                                                  Text(widget.book.year.trim() ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 11)),
                                                  const Text('.'),
                                                  Text(widget.book.size.trim() ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 11)),
                                                  const Text('.'),
                                                  Text(widget.book.downloads.trim() ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 11)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text("by ${snapshot.data!.bookAuthorMain}", style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 12, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap:(){
                                                        Navigator.push(context, MaterialPageRoute(
                                                          builder: (BuildContext context) => PdfView(book:widget.book.linkToInfo),
                                                        ));

                                                  },
                                                      child: AnimatedOpacity(
                                                          duration: const Duration(milliseconds: 200),
                                                          opacity: animateOpacity ? 0.2 : 1.0,
                                                          curve: Curves.bounceInOut,
                                                          onEnd: () {
                                                            setState(() {
                                                              animateOpacity = false;
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: const BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.black38
                                                            ),
                                                            alignment: Alignment.center,
                                                            child: const Icon(Icons.preview, size: 20,color: Colors.white,),
                                                          ),
                                                      )
                                                    ),
                                                    const SizedBox(width: 10),
                                                    GestureDetector(
                                                      onTap:(){
                                                        downloadBook(widget.book);
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: const BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.black38
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: const Icon(Icons.download, size: 20, color: Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      const SizedBox(width: 3,),
                                    ],
                                  )
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text('Suggested Books'),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.suggestedBooks.length,
                                  itemBuilder: (context, index){
                                    return Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (BuildContext context) => InfoView(book: snapshot.data!.suggestedBooks[index]),
                                          ));

                                        },
                                        child: Container(
                                            height: 70,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black54,
                                                    blurRadius: 6.0,
                                                    offset: Offset(0.0, 0.5)
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 3,
                                                    child: ClipRRect(
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8),  ),
                                                        child: Image.network(snapshot.data!.suggestedBooks[index].image.trim(), fit: BoxFit.fill,))
                                                ),
                                                const SizedBox(width: 3,),
                                                Expanded(
                                                    flex: 8,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(snapshot.data!.suggestedBooks[index].title, style: GoogleFonts.mcLaren(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Text(snapshot.data!.suggestedBooks[index].pages.trim() ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 11)),
                                                            const Text('.'),
                                                            Text(snapshot.data!.suggestedBooks[index].year.trim() ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 11)),
                                                            const Text('.'),
                                                            Text(snapshot.data!.suggestedBooks[index].size.trim() ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 11)),
                                                            const Text('.'),
                                                            Text(snapshot.data!.suggestedBooks[index].downloads.trim() ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 11)),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(snapshot.data!.suggestedBooks[index].ifNew, style: GoogleFonts.mcLaren(color: Colors.red,fontSize: 12)),
                                                          ],
                                                        )

                                                      ],
                                                    )
                                                ),
                                                const SizedBox(width: 3,),
                                              ],
                                            )
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
          } else {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }
        });

  }
}



Future<void> downloadBook(BookModel book) async {
  String bookDownloadUrl = await getBookUrl(book);
  if (bookDownloadUrl != '') {
    Directory applicationDocumentDir = await getApplicationDocumentsDirectory();
    String path = applicationDocumentDir.path;
    String _pathToBooks = path + "/assets";
    final savedDir = Directory(_pathToBooks);
    if (await savedDir.exists()) {
      String? taskId = await FlutterDownloader.enqueue(
          url: bookDownloadUrl,
          savedDir: _pathToBooks,
          fileName: book.title+".pdf",
          showNotification: true,
      );
      if (taskId != null) {
        Map<String, dynamic> bookk = {
          "title": book.title,
          "taskId": taskId,
          "bookCoverImage": book.image,
          "fileName": book.title + ".pdf"
        };
        BookFSD bookFSD = BookFSD.fromJson(bookk);
        String books = await SharedServices.getBooks();
        List<BookFSD> booksFSD = [];
        if (books == '') {
            booksFSD = [bookFSD];
            SharedServices.saveBooks(BookFSDToJson(booksFSD));
            print(BookFSDToJson(booksFSD));
        }else {
          List<BookFSD> booksFSD = BookFSDFromJson(books);
          int contains = booksFSD.indexWhere((ele) => ele.taskId == bookFSD.taskId);
          if (contains == -1) {
            booksFSD.add(bookFSD);
            SharedServices.saveBooks(BookFSDToJson(booksFSD));
          } else {
            SharedServices.saveBooks(BookFSDToJson(booksFSD));
          }
        }
      }
    } else {
      await savedDir.create(recursive: true).then((value) async {
        String? taskId = await FlutterDownloader.enqueue(
            url: bookDownloadUrl,
            savedDir: _pathToBooks,
            fileName: book.title + ".pdf",
            showNotification: true,
        );
        if (taskId != null) {
          Map<String, dynamic> bookk = {
            "title": book.title,
            "taskId": taskId,
            "bookCoverImage": book.image,
            "fileName": book.title + ".pdf",
          };
          BookFSD bookFSD = BookFSD.fromJson(bookk);
          String books = await SharedServices.getBooks();
          List<BookFSD> booksFSD = [];
          if (books == '') {
            booksFSD.add(bookFSD);
            SharedServices.saveBooks(BookFSDToJson(booksFSD));
          }else {
            List<BookFSD> booksFSD = BookFSDFromJson(books);
            int contains = booksFSD.indexWhere((ele) => ele.taskId == bookFSD.taskId);
            if (contains == -1) {
              booksFSD.add(bookFSD);
              SharedServices.saveBooks(BookFSDToJson(booksFSD));
            } else {
              SharedServices.saveBooks(BookFSDToJson(booksFSD));
            }
          }
        }

      }
      );}
      }
      }

Future<String> getBookUrl(BookModel book) async {
    String url = 'https://bookish.herokuapp.com/api/bookishInfo.php?bookinfolink=${book.linkToInfo}&getbookpdf=true';
    http.Response response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      final downloadLink = jsonDecode(response.body);
      return downloadLink;
    }
  return '';

}

BookInfo bookInfoFromJson(String str) => BookInfo.fromJson(json.decode(str));

String bookInfoToJson(BookInfo data) => json.encode(data.toJson());

class BookInfo {
  BookInfo({
    required this.bookAuthorMain,
    required this.suggestedBooks,
  });

  late final String bookAuthorMain;
  late final List<BookModel> suggestedBooks;

  factory BookInfo.fromJson(Map<String, dynamic> json) => BookInfo(
    bookAuthorMain: json["bookAuthorMain"],
    suggestedBooks: List<BookModel>.from(json["suggestedBooks"].map((x) => BookModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "bookAuthorMain": bookAuthorMain,
    "suggestedBooks": List<dynamic>.from(suggestedBooks.map((x) => x.toJson())),
  };
}


