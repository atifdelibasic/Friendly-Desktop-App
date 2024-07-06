import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import '../domain/rateapp_response.dart';
import '../domain/rateapp.dart';
import '../helper.dart';
import '../services/rate_app_service.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({Key? key}) : super(key: key);

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  final RateAppService _rateAppService =
      RateAppService(baseUrl: 'https://api.example.com');
  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<RateApp> rateApps = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchRates();
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

  Future<void> fetchRates() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      RateAppResponse response =
          await _rateAppService.fetchRates(searchText, currentPage);
      setState(() {
        rateApps = response.rateapp;
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

    fetchRates();
  }

  Future<void> _showFeedbackModal(RateApp feedback) async {
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
                'Rate app review:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildStarRating(feedback.rating), // Display star rating
              SizedBox(height: 10),
              Text('User ID: ${feedback.user.id}'),
              SizedBox(height: 10),
              // CircleAvatar(
              //   radius: 30,
              //   backgroundImage: feedback.user.profileImage != null
              //       ? NetworkImage(feedback.user.profileImage!)
              //       : AssetImage('assets/default_user_image.png'), // Default placeholder image
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStarRating(double rating) {
    int filledStars = rating.floor();
    double fraction = rating - filledStars;
    List<Widget> starWidgets = [];

    // Add filled stars
    for (int i = 0; i < filledStars; i++) {
      starWidgets.add(Icon(Icons.star, color: Colors.yellow));
    }

    // Add half star if fraction is greater than 0
    if (fraction > 0) {
      starWidgets.add(Icon(Icons.star_half, color: Colors.yellow));
    }

    // Add empty stars to fill up to 5 stars
    for (int i = starWidgets.length; i < 5; i++) {
      starWidgets.add(Icon(Icons.star_border, color: Colors.yellow));
    }

    return Row(
      children: starWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Ratings'),
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
          Text("Hint: Search by rate 1 to 5."),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error))
                    : rateApps.isEmpty
                        ? Center(child: Text('No ratings found.'))
                        : ListView.builder(
                            itemCount: rateApps.length,
                            itemBuilder: (context, index) {
                              RateApp rate = rateApps[index];
                              return InkWell(
                                onTap: () => _showFeedbackModal(rate),
                                child: Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    title: _buildStarRating(rate.rating),
                                    subtitle: Text(
                                        '${rate.user.firstName} ${rate.user.lastName} - ${formatDateString(rate.dateCreated)}'),
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
              await fetchRates();
            },
            useGroup: false,
            totalPage: (count / 10).ceil() == 0 ? 1 : (count / 10).ceil(),
            show: (count / 10).ceil() <= 1 ? 0 : (count / 10).ceil() - 1,
            currentPage: currentPage,
          ),
        ],
      ),
    );
  }
}
