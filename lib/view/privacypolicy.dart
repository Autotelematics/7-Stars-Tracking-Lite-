import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfAssetPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfAssetPath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Remove top safe area inset
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0, // Remove shadow
          backgroundColor: Colors.white, // Match AppSettingsScreen theme
          flexibleSpace: Container(), // Ensure no extra space
        ),
      ),
      body: SafeArea(
        top: false, // Disable top safe area
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )
                : SfPdfViewer.asset(
                    widget.pdfAssetPath,
                    initialScrollOffset:
                        const Offset(0, 0), // Start at top-left
                    scrollDirection:
                        PdfScrollDirection.vertical, // Vertical scroll
                    pageLayoutMode:
                        PdfPageLayoutMode.continuous, // Continuous scroll
                    onDocumentLoadFailed: (details) {
                      setState(() {
                        _errorMessage =
                            'Failed to load ${widget.title} PDF: ${details.description}';
                      });
                    },
                    onDocumentLoaded: (details) {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
      ),
    );
  }
}
