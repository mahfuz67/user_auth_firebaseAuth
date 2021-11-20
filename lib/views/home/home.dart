import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:signup_signin/main.dart';
import 'package:signup_signin/views/home/pdf.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController controller = TextEditingController();
  List<BookModel> books = [];
  String book = '';
  bool animateOpacity = false;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              padding: const EdgeInsets.all(5),
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    flex: 13,
                    child: TextField(
                      controller: controller,
                      autofocus: false,
                      cursorColor: Colors.black,
                      cursorWidth: 1,
                      cursorHeight: 22,
                      textInputAction: TextInputAction.done,
                      style: GoogleFonts.mcLaren(color: Colors.black),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.all(11),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'get books',
                        hintStyle: GoogleFonts.mcLaren(color: Colors.black45),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.5,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: ()async {
                        setState(() {
                          animateOpacity = true;
                        });
                        if(controller.text.isNotEmpty){
                          final query = controller.text;
                            String url = 'https://bookish.herokuapp.com/api/bookishSearch.php?q=$query&page=1';
                             Response response = await http.get(Uri.parse(url));
                             if(response.statusCode == 200){
                               final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
                               final result = parsed.map<BookModel>((json) => BookModel.fromJson(json)).toList();
                               print(parsed);
                               if(mounted){
                                 setState(() {
                                   books = result;
                                 });
                               }
                             }
                        }
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
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            alignment: Alignment.center,
                            child:const Icon(Icons.search, color: Colors.white),
                        )
                      )
                    ),
                  )
                ],
              ),
            ),
            books.isNotEmpty ?
            Expanded(
              child: SizedBox(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: books.length,
                    itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: GestureDetector(
                          onTap: () async {
                            if(mounted){
                              setState(() {
                                isloading = true;
                              });
                            }
                            String url = 'https://bookish.herokuapp.com/api/bookishInfo.php?bookinfolink=${books[index].linkToInfo}&getbookpdf=true';
                            Response response = await http.get(Uri.parse(url));
                            if(response.statusCode == 200){
                              final parsed = jsonDecode(response.body);
                              setState(() {
                                isloading = false;
                              });
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) => PdfView(pdf: parsed),
                                ));
                              print(parsed);
                              if(mounted){
                                setState(() {
                                  book = parsed;
                                });
                              }
                            }

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
                                          child: Image.network(books[index].image.trim(), fit: BoxFit.fill,))
                                  ),
                                  const SizedBox(width: 3,),
                                  Expanded(
                                      flex: 8,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(books[index].title, style: GoogleFonts.mcLaren(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(books[index].pages.trim() ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 11)),
                                              const Text('.'),
                                              Text(books[index].year.trim() ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 11)),
                                              const Text('.'),
                                              Text(books[index].size.trim() ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 11)),
                                              const Text('.'),
                                              Text(books[index].downloads.trim() ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 11)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(books[index].ifNew, style: GoogleFonts.mcLaren(color: Colors.red,fontSize: 12)),
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
              ),
            ) : Container(),
          ]

        )
        )
      );
  }

  // Widget Tile() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Container(
  //       height: 70,
  //       width: MediaQuery.of(context).size.width,
  //       child: Row(
  //         children: [
  //           Expanded(
  //             flex: 3,
  //             child: Image.network(books[index].image, fit: BoxFit.fill,)
  //           ),
  //           Expanded(
  //             flex: 8,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(books[index].title, style: GoogleFonts.mcLaren(color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(books[index].pages ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 12)),
  //                     Text('.'),
  //                     Text(books[index].year ,style: GoogleFonts.mcLaren(color: Colors.black, fontSize: 12)),
  //                     Text('.'),
  //                     Text(books[index].size ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 12)),
  //                     Text('.'),
  //                     Text(books[index].downloads ,style: GoogleFonts.mcLaren(color: Colors.black,fontSize: 12)),
  //                     Text('.'),
  //                     Text(books[index].ifNew.trim(), style: GoogleFonts.mcLaren(color: Colors.red,fontSize: 12)),
  //                   ],
  //                 ),
  //
  //               ],
  //             )
  //           ),
  //         ],
  //       )
  //     ),
  //   );
  // }
}
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

  BookModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    image = json['image'];
    title = json['title'];
    pages = json['pages'];
    year = json['year'];
    size = json['size'];
    ifNew = json['ifNew'];
    downloads = json['downloads'];
    linkToInfo = json['linkToInfo'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['image'] = image;
    _data['title'] = title;
    _data['pages'] = pages;
    _data['year'] = year;
    _data['size'] = size;
    _data['ifNew'] = ifNew;
    _data['downloads'] = downloads;
    _data['linkToInfo'] = linkToInfo;
    return _data;
  }
}
