import 'dart:async';
import 'dart:convert';
import 'package:desktop_friendly_app/domain/hobby_category.dart';
import 'package:desktop_friendly_app/domain/hobby_category_response.dart';
import 'package:desktop_friendly_app/domain/hobby_response.dart';
import 'package:desktop_friendly_app/services/hobby_category_service.dart';
import 'package:desktop_friendly_app/services/hobby_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:http/http.dart' as http;
import '../app_url.dart';
import '../domain/hobby.dart';
import '../shared_preference.dart';

class HobbyScreen extends StatefulWidget {
  const HobbyScreen({super.key});

  @override
  State<HobbyScreen> createState() => _HobbyScreenState();
}

class _HobbyScreenState extends State<HobbyScreen> {
  final HobbyService _hobbyService = HobbyService(baseUrl: 'https://api.example.com');
  final HobbyCategoryService _hobbyCategoryService = HobbyCategoryService(baseUrl: 'https://api.example.com');
  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<Hobby> hobbies = [];
  late HobbyCategoryResponse hobbyCategories;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchHobbies();
    fetchHobbyCategories();
  }

   @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchHobbyCategories() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      HobbyCategoryResponse response = await _hobbyCategoryService.fetchHobbyCategories(searchText, currentPage, 10);
      setState(() {
        hobbyCategories = response;
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

  Future<void> fetchHobbies() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      HobbyResponse response = await _hobbyService.fetchHobby(searchText, currentPage, 10);
      setState(() {
        hobbies = response.hobbies;
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

    fetchHobbies();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchTextChanged(query);
    });
  }

  Future<void> createHobbyCategory(String name, int id) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'name': name, 'hobbyCategoryId': id, 'decsription': "asdasdasdasd"};

    final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}/hobby'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      print(response.body.toString());
      throw Exception('Failed to create category');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Hobby created successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchHobbies();
    }
  }

  Future<void> updateHobbyCategory(int id, String name, int hobbyCategoryId) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'title': name, 'description': 'testiranje', 'hobbyCategoryId': hobbyCategoryId };

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/hobby/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update hobby');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Hobby updated successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchHobbies();
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
              Text('Hobbies'),
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
              'Be careful with deleting hobbies. Some users may use them. ',
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
                        rows: hobbies.map((hobbyCategory) {
                          return DataRow(
                            cells: [
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(hobbyCategory.title),
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
                                    _showEditHobbyModal(context, hobbyCategory);
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
                      await fetchHobbies();
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
        tooltip: 'Create Hobby',
        child: const Icon(Icons.add),
      ),
    );
  }

  

  void _showCreateHobbyCategoryModal(BuildContext context) {
    String hobbyCategoryName = '';
    int selectedHobbyCategory = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Hobby'),
          content:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                hobbyCategoryName = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter hobby name',
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<HobbyCategory>(
              onChanged: (HobbyCategory? value) {
                setState(() {
                  selectedHobbyCategory = value!.id;
                });
              },
              items: hobbyCategories.hobbyCategories.map((HobbyCategory country) {
                return DropdownMenuItem<HobbyCategory>(
                  value: country,
                  child: Text(country.name),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Hobby Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                  await createHobbyCategory(hobbyCategoryName, selectedHobbyCategory);
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

              String uri = "${AppUrl.baseUrl}/hobby/$id";

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
                fetchHobbies();

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

 void _showEditHobbyModal(BuildContext context, Hobby hobby) {
    final TextEditingController nameController = TextEditingController(text: hobby.title);
    HobbyCategory? selectedHobby = hobbyCategories.hobbyCategories.firstWhere((c) => c.id == hobby.hobbyCategoryId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Hobby'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Hobby Name'),
              ),
              DropdownButtonFormField<HobbyCategory>(
                value: selectedHobby,
                onChanged: (HobbyCategory? newValue) {
                  print(newValue!.id);
                  setState(() {
                    selectedHobby = newValue;
                  });
                },
                items: hobbyCategories.hobbyCategories.map<DropdownMenuItem<HobbyCategory>>((HobbyCategory country) {
                  return DropdownMenuItem<HobbyCategory>(
                    value: country,
                    child: Text(country.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Hobby Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                updateHobbyCategory(hobby.id, nameController.text, selectedHobby!.id);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


}
