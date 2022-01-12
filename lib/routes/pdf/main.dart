import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/util/snackbar.dart';

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
  File _tempFile;
  PDFDocument _pdfFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timestamp) {
      _initPdf();
    });
  }

  @override
  void dispose() {
    _deleteTempFile();
    super.dispose();
  }

  _initPdf() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final pdfFile = await PDFDocument.fromURL(widget.url.trim());

      setState(() {
        _pdfFile = pdfFile;
        _isLoading = false;
      });
    } catch (e) {
      final snackBar = createErrorSnackbar(
          text: "There was an error loading the PDF. Please try again later");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: widget.title != null ? Subtitle1(widget.title) : null,
      ),
      body: _body(),
      backgroundColor: Colors.white,
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return PDFViewer(
      document: _pdfFile,
      zoomSteps: 1,
    );
  }

  _deleteTempFile() {
    _tempFile?.delete();
  }
}
