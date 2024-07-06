import 'dart:async';
import 'dart:convert';

import 'package:desktop_friendly_app/country_response.dart';
import 'package:desktop_friendly_app/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:http/http.dart' as http;
import '../app_url.dart';
import '../country.dart';
import '../services/country_service.dart';
import '../shared_preference.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final CountryService _countryService = CountryService(baseUrl: 'https://api.example.com');
  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<Country> countries = [];
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
    fetchCountries();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      CountryResponse response = await _countryService.fetchCountries(searchText, currentPage, 10);
      setState(() {
        countries = response.countries;
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

    fetchCountries();
  }

  Future<void> createCountry(String name) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'name': name};

    final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}/country'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create country');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Country created successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchCountries();
    }
  }

  Future<void> updateCountry(int id, String name) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'name': name};

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/country/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update country');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Country updated successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchCountries();
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
              Icon(Icons.location_pin),
              SizedBox(width: 10),
              Text('Countries'),
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
              'Be careful with deleting countries. Changing Active state will do soft delete and those countries will not be shown to the users.',
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
                              child: Text('ID'),
                            ),
                          ),
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
                              child: Text('Edit'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text('Active'),
                            ),
                          ),
                        ],
                        rows: countries.map((country) {
                          return DataRow(
                            cells: [
                              DataCell(SizedBox(
                                width: 10,
                                child: Text(country.id.toString()),
                              )),
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(country.name),
                              )),
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(formatDateString(country.dateCreated)),
                              )),
                              DataCell(SizedBox(
                                width: 50,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCountryModal(context, country);
                                  },
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 50,
                                child: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Switch(
                                      value: country.deletedAt == null,
                                      onChanged: (bool value) async {
                                        setState(() {
                                          country.deletedAt = !value ? DateTime.now().toIso8601String() : null;
                                        });
                                        await deleteCountry(country.id, !value);
                                      },
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
                      await fetchCountries();
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
          _showCreateCountryModal(context);
        },
        tooltip: 'Create Country',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCountryModal(BuildContext context) {
    String countryName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Country'),
          content: TextField(
            onChanged: (value) {
              countryName = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter country name',
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
                if (countryName.isNotEmpty) {
                  await createCountry(countryName);
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

  void _showEditCountryModal(BuildContext context, Country country) {
  TextEditingController textEditingController = TextEditingController(text: country.name);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Country'),
        content: TextField(
          controller: textEditingController, // Use the controller to set initial value
          onChanged: (value) {
            // You can remove this onChanged callback if you don't need it
          },
          decoration: InputDecoration(
            hintText: 'Enter country name',
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
              String updatedCountryName = textEditingController.text;
              if (updatedCountryName.isNotEmpty) {
                await updateCountry(country.id, updatedCountryName);
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
