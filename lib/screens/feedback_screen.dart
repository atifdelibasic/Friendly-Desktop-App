import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import '../domain/feedback_response.dart';
import '../domain/feedback.dart';
import '../helper.dart';
import '../services/feedback_srevice.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService(baseUrl: 'https://api.example.com');
  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<FeedbackCustom> feedbacks = [];
  Timer? _debounce;

   void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchTextChanged(query);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchFeedbacks() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      FeedbackResponse response = await _feedbackService.fetchFeedbacks(searchText, currentPage);
      setState(() {
        feedbacks = response.feedbacks;
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

  void searchTextChanged(String text) {
    setState(() {
      searchText = text;
      currentPage = 1;
    });

    fetchFeedbacks();
  }

  Future<void> _showFeedbackModal(FeedbackCustom feedback) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feedback:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                feedback.text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedbacks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error))
                    : feedbacks.isEmpty
                        ? Center(child: Text('No feedbacks found.'))
                        : ListView.builder(
                            itemCount: feedbacks.length,
                            itemBuilder: (context, index) {
                              FeedbackCustom feedback = feedbacks[index];
                              return InkWell(
                                onTap: () => _showFeedbackModal(feedback),
                                child: Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    title: Text(feedback.text),
                                    subtitle: Text('${feedback.user?.firstName} ${feedback.user?.lastName} - ${formatDateString(feedback.dateCreated)}'),
                                  ),
                                ),
                              );
                            },
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
              await fetchFeedbacks();
            },
            useGroup: false,
            totalPage: (count / 10).ceil() == 0 ? 1 : (count / 10).ceil(),
            show: count <= 30 || count == 0 ? 0 : 3,
            currentPage: currentPage,
          ),
        ],
      ),
    );
  }
}
