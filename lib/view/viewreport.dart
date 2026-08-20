import 'dart:developer';
import 'package:autotelematic_new_app/cubit/get_reports_cubit.dart';
import 'package:autotelematic_new_app/model/viewreportinitialdata.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/app_constants.dart';
import 'package:autotelematic_new_app/utils/date_time_extension.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewReportsScreen extends StatefulWidget {
  final String reportName;
  final ViewReportIntialData viewReportIntialData;

  const ViewReportsScreen({
    super.key,
    required this.viewReportIntialData,
    required this.reportName,
  });

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  bool _hasLaunchedBrowser = false;
  String startDate = '', endDate = '';

  @override
  void initState() {
    super.initState();
    context.read<GetReportsCubit>().fetchReportsfromAPI(widget.viewReportIntialData);
    log("Report Type: ${widget.viewReportIntialData.reportType}");

    // Format start and end dates with time
    try {
      final dateFormat = DateFormat("yy-MM-dd");
      final timeFormat = DateFormat("HH:mm:ss");

      final startD = dateFormat.parse(widget.viewReportIntialData.fromDate ?? "");
      final startT = timeFormat.parse(widget.viewReportIntialData.fromTime);
      final startDateTime = DateTime(startD.year, startD.month, startD.day, startT.hour, startT.minute, startT.second);
      startDate = startDateTime.historyDateTime;

      final endD = dateFormat.parse(widget.viewReportIntialData.toDate ?? "");
      final endT = timeFormat.parse(widget.viewReportIntialData.toTime);
      final endDateTime = DateTime(endD.year, endD.month, endD.day, endT.hour, endT.minute, endT.second);
      endDate = endDateTime.historyDateTime;
    } catch (e) {
      startDate = widget.viewReportIntialData.fromDate ?? "";
      endDate = widget.viewReportIntialData.toDate ?? "";
    }
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20.sp, weight: 3),
      ),
    );
  }

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.png') || lowerUrl.endsWith('.jpg') || lowerUrl.endsWith('.jpeg') || lowerUrl.endsWith('.gif');
  }

  bool _isHtmlContent(ViewReportIntialData data) {
    return data.reportType == 43 && data.reportFormat?.toLowerCase() == 'html';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(widget.reportName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateItem("From", startDate),
                _buildDateItem("To", endDate),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: BlocBuilder<GetReportsCubit, GetReportsState>(
              builder: (context, state) {
                if (state is GetReportsLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTheme.loadingImage,
                        const SizedBox(height: 5),
                        const Text('Loading report data...'),
                      ],
                    ),
                  );
                }

                if (state is GetReportsError) {
                  return Center(child: Text(state.message));
                }

                if (state is GetReportsLoadingComplete) {
                  final url = state.getReportModel.url!;
                  log("Report URL: $url");

                  // Check if the report is HTML content (report type 43 with html format)
                  if (_isHtmlContent(widget.viewReportIntialData)) {
                    if (!_hasLaunchedBrowser) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        setState(() {
                          _hasLaunchedBrowser = true;
                        });
                        try {
                          await CommonUtils.launchURLBrowser(url);
                          await Future.delayed(const Duration(seconds: 1));
                          if (mounted) {
                            Navigator.pop(context); // Close screen after browser opens
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to open browser: $e')),
                            );
                            setState(() {
                              _hasLaunchedBrowser = false; // Allow retry on error
                            });
                          }
                        }
                      });
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTheme.loadingImage,
                          const SizedBox(height: 5),
                          const Text('Opening map report in browser...'),
                          const SizedBox(height: 10),
                          if (_hasLaunchedBrowser)
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Manual close if browser doesn't open
                              },
                              child: const Text('Close'),
                            ),
                        ],
                      ),
                    );
                  }

                  // Check if the URL is an image
                  if (_isImageUrl(url)) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Center(
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                'Failed to load image',
                                style: TextStyle(fontSize: 14.sp, color: Colors.red),
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                        Positioned(
                          top: 3.h,
                          right: 3.w,
                          child: Row(
                            children: [
                              _buildActionButton(
                                icon: Icons.download,
                                color: const Color(0xffFBB117),
                                onTap: () => CommonUtils.launchURLBrowser(url),
                              ),
                              SizedBox(width: 3.w),
                              _buildActionButton(
                                icon: Icons.share,
                                color: Colors.green,
                                onTap: () => Share.share(url),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Default case: Assume it's a PDF
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      SfPdfViewer.network(
                        url,
                        initialZoomLevel: 0,
                        pageSpacing: 0,
                        enableDoubleTapZooming: true,
                        pageLayoutMode: PdfPageLayoutMode.continuous,
                        onDocumentLoadFailed: (details) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to load PDF: ${details.description}')),
                          );
                        },
                      ),
                      Positioned(
                        top: 3.h,
                        right: 3.w,
                        child: Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.download,
                              color: const Color(0xffFBB117),
                              onTap: () => CommonUtils.launchURLBrowser(url),
                            ),
                            SizedBox(width: 3.w),
                            _buildActionButton(
                              icon: Icons.share,
                              color: Colors.green,
                              onTap: () => Share.share(url),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String value) {
    return Column(
      crossAxisAlignment: label == "From" ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined, size: 14.sp, color: AppColors.primaryColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF424242), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
