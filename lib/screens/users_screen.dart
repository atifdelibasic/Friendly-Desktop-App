import 'dart:convert';
import 'package:desktop_friendly_app/app_url.dart';
import 'package:desktop_friendly_app/screens/create_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:http/http.dart' as http;

import '../shared_preference.dart';
import '../user.dart';
import 'edit_profile_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 1;
  List<User> dataList = [];
  String searchText = '';
  int count = 0;

  @override
  void initState() {
    super.initState();
    fetchData(currentPage);
  }

  void searchTextChanged(String text) {
    setState(() {
      searchText = text;
 
      currentPage = 1;
    });
    fetchData(currentPage, searchText);
  }

  Future<void> fetchData(int page, [String? searchQuery]) async {
    String uri = '${AppUrl.baseUrl}/User?page=${currentPage - 1}&PageSize=10';
    if (searchQuery != null && searchQuery.isNotEmpty) {
      uri += '&text=$searchQuery';
    }

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiaXNzIjoiaHR0cDovL2ZyaWVuZGx5LmFwcCIsImF1ZCI6Imh0dHA6Ly9mcmVpbmRseS5hcHAifQ.DQyZXVrt7gBSSJyfXyd21fzxuhT2Ts4i4s4D0juPXso',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> data = responseData['result'];
      final int countRes = responseData['count'];

      final List<User> items = data.map((data) {
        return User.fromJson(data);
      }).toList();

      setState(() {
        count = countRes;
        dataList = items;
      });
    }
  }

   void deleteItem(int id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String token = await UserPreferences().getToken();
              User user = await UserPreferences().getUser();

              if(user.id == id) {
                showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('You cannot delete yourself.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
              }


              String uri = "${AppUrl.baseUrl}/User/delete/$id";

              var res = await http.delete(
                Uri.parse(uri),
                headers: {
                  'Authorization': 'Bearer $token',
                },
              );

              if (res.statusCode == 200) {
               
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('User deleted successfully!', style: TextStyle(color: Colors.white)),
                  ),
                );
                fetchData(currentPage);

              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Something went wrong!', style: TextStyle(color: Colors.white)),
                  ),
                );
                print('Failed to delete the item: ${res.statusCode}');
              }

              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: searchTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
           ElevatedButton(
          onPressed: () {
               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Register(),
                                  ),
                                    );
          },
          child: Text('Create User'),
        ),
          ],
        ),
        SizedBox(height: 10),
        dataList.isNotEmpty
            ? DataTable(
              border: TableBorder.all(),
              columnSpacing: 100,
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('First name')),
                  DataColumn(label: Text('Last name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: dataList
                    .map((data) => DataRow(
                          cells: [
                            DataCell(Container( child: Text(data.id.toString() , overflow: TextOverflow.ellipsis)),),

                            DataCell(Container( width: 100, child: Text(data.firstName  , overflow: TextOverflow.ellipsis)),),
                            DataCell(Container( width: 100, child: Text(data.lastName , overflow: TextOverflow.ellipsis)),),
                            DataCell(Container( width: 200, child: Text(data.email , overflow: TextOverflow.ellipsis)),),
                            DataCell(
                             Row(
                              children: [
                                IconButton(
                                  icon:const Icon(Icons.delete),
                                  onPressed: () {
                                    deleteItem(data.id);
                                  },
                                ),
                                IconButton(
                                icon:const Icon(Icons.edit),
                                onPressed: () {
                                 
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(user: data),
                                  ),
                                    );

                                    
                                  },
                                ),
                              ],
                            ),
                          ),
                          ],
                        ))
                    .toList(),
              )
            : const Text("No data"),
        const SizedBox(height: 20),
        // Pagination Widget
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
          onPageChange: (number) {
            setState(() {
              currentPage = number;
            });
            fetchData(currentPage, searchText);
          },
          useGroup: false,
            totalPage: (count / 10).ceil() == 0 ? 1 : (count / 10).ceil(),
            show: (count / 10).ceil() <= 1 ? 0 : (count / 10).ceil() - 1,
          currentPage: currentPage,
        ),
      ],
    ),
    ),
        appBar: AppBar(
          title: const Text('Users'),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
      );
      }
}
