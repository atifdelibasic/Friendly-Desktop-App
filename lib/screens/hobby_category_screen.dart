import 'dart:convert';
import 'package:desktop_friendly_app/domain/hobby_category.dart';
import 'package:desktop_friendly_app/domain/hobby_category_response.dart';
import 'package:desktop_friendly_app/helper.dart';
import 'package:desktop_friendly_app/services/hobby_category_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:http/http.dart' as http;
import '../app_url.dart';
import '../country.dart';
import '../shared_preference.dart';
import '../user.dart';

class HobbyCategoryScreen extends StatefulWidget {
  const HobbyCategoryScreen({super.key});

  @override
  State<HobbyCategoryScreen> createState() => _HobbyCategoryScreenState();
}

class _HobbyCategoryScreenState extends State<HobbyCategoryScreen> {
  final HobbyCategoryService _hobbyCategoryService = HobbyCategoryService(baseUrl: 'https://api.example.com');
  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<HobbyCategory> hobbyCategories = [];

  @override
  void initState() {
    super.initState();
    fetchHobbyCategories();
  }

  Future<void> fetchHobbyCategories() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      HobbyCategoryResponse response = await _hobbyCategoryService.fetchHobbyCategories(searchText, currentPage, 10);
      setState(() {
        hobbyCategories = response.hobbyCategories;
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

    fetchHobbyCategories();
  }

  Future<void> createHobbyCategory(String name) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'name': name};

    final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}/hobbycategory'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create hobby category');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Hobby category created successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchHobbyCategories();
    }
  }

  Future<void> updateHobbyCategory(int id, String name) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'name': name};

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/hobbycategory/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update hobby category');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Hobby category updated successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchHobbyCategories();
    }
  }

  Future<void> deleteCountry(int countryId, bool isDeleted) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/country/delete?id=' + countryId.toString() + '&isDeleted=' + isDeleted.toString()),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update country');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Country updated successfully!', style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Row(
            children: [
              Text('Hobby categories'),
            ],
          ),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                const SizedBox(width: 10),
                
              ],
            ),
          ),
          Card(
      color: Colors.yellow[100],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.yellow[800]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Warning!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Be careful with categories countries.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.yellow[900],
              ),
            ),
            SizedBox(height: 16),
          
          ],
        ),
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
                              child: Text('Name'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 150,
                              child: Text('Date created'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text('Actions'),
                            ),
                          ),
                        
                        ],
                        rows: hobbyCategories.map((hobbyCategory) {
                          return DataRow(
                            cells: [
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(hobbyCategory.name),
                              )),
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(hobbyCategory.dateCreated),
                              )),
                             DataCell(
                             Row(
                              children: [
                                IconButton(
                                  icon:const Icon(Icons.delete,  color: Colors.red,),
                                  onPressed: () {
                                    deleteItem(hobbyCategory.id);
                                  },
                                ),
                                IconButton(
                                icon:const Icon(Icons.edit, color: Colors.blueGrey),
                                onPressed: () {
                                    _showEditCountryModal(context, hobbyCategory);
                                  },
                                ),
                              ],
                            ),
                          ),
                              
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
                      await fetchHobbyCategories();
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateHobbyCategoryModal(context);
        },
        tooltip: 'Create Hobby Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateHobbyCategoryModal(BuildContext context) {
    String hobbyCategoryName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Hobby Category'),
          content: TextField(
            onChanged: (value) {
              hobbyCategoryName = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (hobbyCategoryName.isNotEmpty) {
                  await createHobbyCategory(hobbyCategoryName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void deleteItem(int id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure?'),
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

              String uri = "${AppUrl.baseUrl}/hobbycategory/$id";

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
                    content: Text('Hobby deleted successfully!', style: TextStyle(color: Colors.white)),
                  ),
                );
                fetchHobbyCategories();

              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Something went wrong!', style: TextStyle(color: Colors.white)),
                  ),
                );
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

  void _showEditCountryModal(BuildContext context, HobbyCategory country) {
  TextEditingController textEditingController = TextEditingController(text: country.name);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Hobby Category'),
        content: TextField(
          controller: textEditingController,
          onChanged: (value) {
          },
          decoration: InputDecoration(
            hintText: 'Enter  name',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String updateHobbyCategoryName = textEditingController.text;
              if (updateHobbyCategoryName.isNotEmpty) {
                await updateHobbyCategory(country.id, updateHobbyCategoryName);
                Navigator.of(context).pop();
              }
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}

}
