import 'dart:async';
import 'dart:convert';
import 'package:desktop_friendly_app/country_response.dart';
import 'package:desktop_friendly_app/helper.dart';
import 'package:http/http.dart' as http;
import 'package:desktop_friendly_app/city.dart';
import 'package:desktop_friendly_app/city_response.dart';
import 'package:desktop_friendly_app/services/city_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';

import '../app_url.dart';
import '../country.dart';
import '../services/country_service.dart';
import '../shared_preference.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final CityService _cityService = CityService(baseUrl: 'https://api.example.com');
  final CountryService _countryService = CountryService(baseUrl: 'https://api.example.com');

  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<City> cities = [];
  late CountryResponse countries;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchCities();
    fetchCountries();
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  Future<void> fetchCountries() async {
    countries = await _countryService.fetchCountries(searchText, currentPage, 100);
  }

  Future<void> createCity(String name, int countryId) async {
    String token =  await UserPreferences().getToken();

    Map<String, dynamic> data = {'name': name, 'countryId' : countryId};

     final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}/city'),
      headers: {  'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          },
          body: jsonEncode(data)
    );

    if (response.statusCode != 200) {
      throw Exception('Failed ');
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: Colors.green, // Set background color to green
    content: Text('City created successfully!', style: TextStyle(color: Colors.white)), // Set text color to white
  ),
);
      fetchCities();
      Navigator.pop(context);
    }
  }

  
  Future<void> editCity( int cityId, String name, int countryId) async {
    String token =  await UserPreferences().getToken();

    Map<String, dynamic> data = {'name': name, 'countryId' : countryId};

     final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/city/$cityId'),
      headers: {  'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          },
          body: jsonEncode(data)
    );

    if (response.statusCode != 200) {
      throw Exception('Failed ');
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: Colors.green, // Set background color to green
    content: Text('City updated successfully!', style: TextStyle(color: Colors.white)), // Set text color to white
  ),
);
      fetchCities();
      Navigator.pop(context);
    }
  }


  Future<void> deleteCity( int cityId, bool isDeleted) async {
    String token =  await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };


     final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/city/delete?id='+ cityId.toString() + '&isDeleted=' + isDeleted.toString()),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed ');
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: Colors.green, // Set background color to green
    content: Text('City updated successfully!', style: TextStyle(color: Colors.white)), // Set text color to white
  ),
);
    }
  }

void _showEditCityModal(BuildContext context, City city) {
    final TextEditingController nameController = TextEditingController(text: city.name);
    Country? selectedCountry = countries.countries.firstWhere((c) => c.id == city.country.id, orElse: () => countries.countries.last);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit City'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'City Name'),
              ),
              DropdownButtonFormField<Country>(
                value: selectedCountry,
                onChanged: (Country? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                  });
                },
                items: countries.countries.map<DropdownMenuItem<Country>>((Country country) {
                  return DropdownMenuItem<Country>(
                    value: country,
                    child: Text(country.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Country'),
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
                editCity(city.id, nameController.text, selectedCountry!.id);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


 void _showCreateCityModal(BuildContext context) {
  String cityName = '';
  Country? selectedCountry;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                cityName = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter city name',
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<Country>(
              value: selectedCountry,
              onChanged: (Country? value) {
                setState(() {
                  selectedCountry = value;
                });
              },
              items: countries.countries.map((Country country) {
                return DropdownMenuItem<Country>(
                  value: country,
                  child: Text(country.name),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Country',
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
              if (cityName.isNotEmpty && selectedCountry != null) {
                // Pass selectedCountry.id when creating the city
                await createCity(cityName, selectedCountry!.id);
              }
            },
            child: Text('Create'),
          ),
        ],
      );
    },
  );
}



  Future<void> fetchCities() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      CityResponse response = await _cityService.fetchCities(searchText, currentPage);
      setState(() {
        cities = response.cities;
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

    fetchCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
         title: const Row(
            children: [
              Icon(Icons.location_city),
              SizedBox(width: 10),
              Text('Cities'),
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
              'Be careful with deleting cities. Changing Active state will do soft delete and those cities will not be shown to the users.',
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
                              width: 150, // Set the width for the column
                              child: Text('ID'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 150, // Set the width for the column
                              child: Text('Name'),
                            ),
                          ),
                           DataColumn(
                            label: SizedBox(
                              width: 150, // Set the width for the column
                              child: Text('Country'),
                            ),
                          ),
                             DataColumn(
                            label: SizedBox(
                              width: 150, // Set the width for the column
                              child: Text('Created at'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100, // Set the width for the column
                              child: Text('Edit'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100, // Set the width for the column
                              child: Text('Active'),
                            ),
                          ),
                        ],
                        rows: cities.map((city) {
                          return DataRow(
                            cells: [
                               DataCell(SizedBox(
                                width: 20, 
                                child: Text(city.id.toString()),
                              )),
                              DataCell(SizedBox(
                                width: 150, 
                                child: Text(city.name),
                              )),
                                DataCell(SizedBox(
                                width: 150, 
                                child: Text(city.country.name),
                              )),
                               DataCell(SizedBox(
                                width: 150, 
                                child: Text(formatDateString(city.dateCreated)),
                              )),
                              DataCell(SizedBox(
                                width: 50, 
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                  _showEditCityModal(context, city);
                                  },
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 50,
                                child: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Switch(
                                        value: city.deletedAt == null, 
                                        onChanged: (bool value) async {
                                          setState(() {
                                            city.deletedAt = !value ? DateTime.now().toIso8601String() : null;
                                          });
                                          await deleteCity(city.id, !value); 
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
                      await fetchCities();
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
          _showCreateCityModal(context);
        },
        tooltip: 'Create City',
        child: const Icon(Icons.add),
      ),
    );
  }
}
