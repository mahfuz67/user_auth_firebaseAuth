import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signup_signin/model/bookmodel.dart';
import 'package:signup_signin/model/bookmodel.dart';
import 'package:signup_signin/services/prefs/prefs.dart';
import 'package:signup_signin/views/home/pdf.dart';
import 'package:signup_signin/views/home/pdfinfo.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController controller = TextEditingController();
  List<BookModel> books = [];
  List<dynamic> booksDownloads = [];
  String book = '';
  bool animateOpacity = false;
  bool isloading = false;

  int indexOfPage = 0;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    getContents();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    _port.close();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });
  }
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }


  Future<List<BookDA>> getContents() async{
     List<DownloadTask>? tasks = await  FlutterDownloader.loadTasksWithRawQuery(
         query: "SELECT * FROM task WHERE status=2"
     );
     List<BookDA> bookDA = [];
     String books = await SharedServices.getBooks();
     if(books != '') {
       List<BookFSD> booksFSD = BookFSDFromJson(books);
       print(books.toString());
       for(int i = 0; i < tasks!.length; i++){
         BookFSD detailsOfThisPdfFromPrefs = booksFSD.firstWhere((e) => e.taskId ==tasks[i].taskId, orElse: () => BookFSD(title: '', taskId: '', bookCoverImage: '', fileName: ''));
         File theBook = File(tasks[i].savedDir+'${tasks[i].filename}');
         bookDA.add(
             BookDA(
               bookDetails: detailsOfThisPdfFromPrefs,
               file: theBook,
         ));
       }
     }
     return bookDA;
   }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: indexOfPage == 1 ? Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getContents(),
                builder: (context, AsyncSnapshot<List<BookDA>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder:  (context, index){
                          return Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) => PdfView(book:snapshot.data![index].file.path),
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
                                              child: Image.network(snapshot.data![index].bookDetails.bookCoverImage, fit: BoxFit.fill,))
                                      ),
                                      const SizedBox(width: 3,),
                                      Expanded(
                                          flex: 8,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(snapshot.data![index].bookDetails.title, style: GoogleFonts.mcLaren(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,),
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
                    );
                  } else {
                    return Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(
                        child: SizedBox(
                          height: 50,
                          width: 140,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Expanded(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Colors.black,
                                ),
                              ),
                              Text('loading preview'),

                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              ),
            )
          ],
        ) :
        Column(
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
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) => InfoView(book: books[index]),
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
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index){
            setState(() {
              indexOfPage = index;
            });
          },
          currentIndex: indexOfPage,
          backgroundColor: Colors.black,
          selectedLabelStyle: GoogleFonts.mcLaren(color: Colors.white),
          unselectedLabelStyle: GoogleFonts.mcLaren(color: Colors.grey),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              label: 'search',
              icon: Icon(Icons.search,  color: Colors.grey),
              activeIcon: Icon(Icons.search,  color: Colors.white),
            ),
            BottomNavigationBarItem(
                label: 'downloads',
                icon: Icon(Icons.download,  color: Colors.grey),
              activeIcon: Icon(Icons.download,  color: Colors.white),
            )
          ],
        ),
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
