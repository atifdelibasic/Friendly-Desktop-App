import 'package:desktop_friendly_app/services/reports_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_url.dart';
import '../post.dart';
import '../report.dart';
import 'package:http/http.dart' as http;

import '../shared_preference.dart';

class ViewPost extends StatefulWidget {
  final Post? post;
  final Report report;
  final void Function() onReportsFetched;


  const ViewPost({super.key, required this.post, required this.report, required this.onReportsFetched});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  final ReportsService _reportsService = ReportsService(baseUrl: 'https://api.example.com');
  late bool isSeen;

  @override
  void initState() {
    super.initState();
    isSeen = widget.report.seen;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    if (post == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View Report'),
          automaticallyImplyLeading: true,
        ),
        body: const Center(
          child: Text('No post data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Post'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.postImage != null && post.postImage.isNotEmpty)
                Center(
                  child: Image.network(
                    post.postImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 200);
                    },
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Post Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildDetailRow('Description', post.description ?? 'No description available'),
              _buildDetailRow('Date Created', _formatDateString(post.dateCreated)),
              _buildDetailRow('Created by', '${post.user.firstName} ${post.user.lastName}'),
              const SizedBox(height: 20),
              const Text(
                'Report Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildDetailRow('Reported by', '${widget.report.user.firstName} ${widget.report.user.lastName}'),
              _buildDetailRow('Report Reason', widget.report.reportReason.description),
              _buildDetailRow('Additional Comment', widget.report.additionalComment ?? 'No additional comments'),
              _buildDetailRow('Reported at', _formatDateString(widget.report.dateCreated)),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: isSeen ? null : () => _markAsSeen(widget.report.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSeen ? Colors.grey : Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isSeen ? 'Seen' : 'Mark as Seen',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _deletePost(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete Post',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSeen)
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsSeen(int reportId) async {
    try {
      await _reportsService.markReportAsSeen(reportId);
      setState(() {
        isSeen = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post marked as seen')),
      );
      widget.onReportsFetched();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark post as seen')),
      );
    }
  }

  
  _deletePost () async {
    print("delete post");
    String token =  await UserPreferences().getToken();

   final response = await http.delete(
        Uri.parse('${AppUrl.baseUrl}/Post/${widget.post!.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("STATUS CODE " + response.statusCode.toString());

      if(response.statusCode == 200) {
         ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
      widget.onReportsFetched();

      Navigator.pop(context);
        print("obrisan");
      } else {
        const SnackBar(content: Text('Something went wrong'));
      }

  }


  String _formatDateString(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
