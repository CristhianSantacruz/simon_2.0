import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewDocumentScreen extends StatefulWidget {
  final String urlDocument;
  final String name;
  final bool? iconDelete;
  final void Function()? onPressedDeleted;
  const PDFViewDocumentScreen(
      {super.key, required this.urlDocument, required this.name , this.iconDelete, this.onPressedDeleted});

  @override
  State<PDFViewDocumentScreen> createState() => _WebViewDocumentScreenState();
}

class _WebViewDocumentScreenState extends State<PDFViewDocumentScreen> {
  late PdfViewerController _pdfViewerController;
  bool isLoading = true;
  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : white_color,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: appStore.isDarkMode ? scaffoldLightColor : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor:   appStore.isDarkMode ? scaffoldDarkColor : white_color,
        title: Text(
          '${widget.name}',
          style:  TextStyle(
              color: appStore.isDarkMode ? scaffoldLightColor : Colors.black,
              fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          if (widget.iconDelete != null)
            IconButton(
              icon: Icon(
                widget.iconDelete! ? Icons.delete : Icons.delete_outline,
                color: appStore.isDarkMode ? Colors.white : simonNaranja,
              ),
              onPressed: widget.onPressedDeleted,
            ),
        ],
      ),
      body: isLoading
          ? SizedBox.expand(
              child: SfPdfViewer.network(
              widget.urlDocument,
              key: const Key('pdf_viewer'),
              controller: _pdfViewerController,
              onDocumentLoaded: (_) {
                setState(() {
                  isLoading = true;
                });
              },
              maxZoomLevel: 5,
            ))
          : const Center(
              child: LoaderAppIcon(),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          
          FloatingActionButton(
            heroTag: "zoom_in",
            backgroundColor: simon_finalPrimaryColor,
            onPressed: () {
              _pdfViewerController.zoomLevel += 0.25;
            },
            child: const Icon(Icons.zoom_in, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            backgroundColor: simon_finalPrimaryColor,
            onPressed: () {
              _pdfViewerController.zoomLevel -= 0.25;
            },
            child: const Icon(Icons.zoom_out, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
