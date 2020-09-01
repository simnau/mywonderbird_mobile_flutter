import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

class PdfPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfPage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  File _pdfFile;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  @override
  void dispose() {
    _deletePdf();
    super.dispose();
  }

  _initPdf() async {
    final pdfFile = await _createFileOfPdfUrl(widget.url);
    setState(() {
      _pdfFile = pdfFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pdfFile == null) {
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
        color: Colors.white,
      );
    }

    return PDFViewerScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      path: _pdfFile?.path,
    );
  }

  Future<File> _createFileOfPdfUrl(url) async {
    final filename = url.substring(url.lastIndexOf('/') + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await Directory.systemTemp.createTemp()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  _deletePdf() {
    _pdfFile?.delete();
  }
}
