import 'dart:async';

import 'package:desktop_friendly_app/report_response.dart';
import 'package:desktop_friendly_app/screens/view_post.dart';
import 'package:desktop_friendly_app/services/reports_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:intl/intl.dart';

import '../helper.dart';
import '../report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsService _reportsService = ReportsService(baseUrl: 'https://api.example.com');

   int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<Report> reports = [];
  Timer? _debounce;

   @override
  void initState() {
    super.initState();

    fetchReports();
  }

   @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

   void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchTextChanged(query);
    });
  }


  void searchTextChanged(String text) {
    setState(() {
      searchText = text;
      currentPage = 1;
    });

    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      ReportResponse response = await _reportsService.fetchReports(searchText, currentPage);
      setState(() {
        print("set state ");
        reports = response.reports;
        count = response.count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Post reports'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (error.isNotEmpty)
                    Center(child: Text(error))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                           DataColumn(
                            label: SizedBox(
                              width: 150, 
                              child: Text('Note'),
                            ),
                          ),
                           DataColumn(
                            label: SizedBox(
                              width: 150, 
                              child: Text('Reported at'),
                            ),
                          ),
                            DataColumn(
                            label: SizedBox(
                              width: 150, 
                              child: Text('Seen by admin'),
                            ),
                          ),
                           DataColumn(
                            label: SizedBox(
                              width: 150, 
                              child: Text('Report reason'),
                            ),
                          ),
                           DataColumn(
                            label: SizedBox(
                              width: 150, 
                              child: Text('Is deleted'),
                            ),
                          ),
                          DataColumn(   label: SizedBox(
                              width: 150, 
                              child: Text('Review'),
                            ),)
                        ],
                        rows: reports.map((report) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                width: 150, 
                                child: Text(report.additionalComment),
                              )),
                                 DataCell(SizedBox(
                                width: 150, 
                                child: Text(formatDateString(report.dateCreated)),
                              )),
                                DataCell(SizedBox(
                                width: 150, 
                                child: Text(report.seen ? "Seen" : "Not seen"),
                              )),
                               DataCell(SizedBox(
                                width: 150, 
                                child: Text(report.reportReason.description),
                              )),
                                DataCell(SizedBox(
                                width: 150, 
                                child: Text(report.post == null ? "Deleted" : "Not deleted"),
                              )),
                                 DataCell(SizedBox(
                                width: 50, 
                                child: IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                     Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewPost(post: report.post, report: report, onReportsFetched: fetchReports),
                                  ),
                                    );
                                  },
                                ),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  Pagination(
                    paginateButtonStyles: PaginateButtonStyles(),
                    prevButtonStyles: PaginateSkipButton(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    nextButtonStyles: PaginateSkipButton(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    onPageChange: (number) async {
                      setState(() {
                        currentPage = number;
                      });
                      await fetchReports();
                    },
                    useGroup: false,
                     totalPage: (count / 10).ceil() == 0 ? 1 : (count / 10).ceil(),
                    show: (count / 10).ceil() <= 1 ? 0 : (count / 10).ceil() - 1,
                    currentPage: currentPage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),);
  }
}
