import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:signup_signin/model/bookmodel.dart';

class PdfView extends StatefulWidget {
  const PdfView({Key? key, required this.book }) : super(key: key);
    final dynamic book;
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {

  Future<String?> getContents() async {
    String url = 'https://bookish.herokuapp.com/api/bookishInfo.php?bookinfolink=${widget.book}&getbookpdf=true';
    http.Response response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      final parsed = jsonDecode(response.body);
      return parsed;
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: widget.book is String ?
        FutureBuilder(
          future: getContents(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
                child: const PDF().cachedFromUrl(
                  snapshot.data!,
                  placeholder: (double progress) => Center(child: Text('$progress %')),
                  errorWidget: (dynamic error) => Center(child: Text(error.toString())),
                  maxNrOfCacheObjects: 50,
                ),
                //SfPdfViewer.network(widget.pdf)
              );
          } else {
            return Center(
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
              );
          }
        }) :
        Center(
          child: const PDF().fromPath(
            widget.book,
          ),
        ),
      ),
    );
  }
}
