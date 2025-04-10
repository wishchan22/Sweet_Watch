import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// FoodSearchPage allows users to search for foods and add them to their log
class FoodSearchPage extends StatefulWidget {
  final Function(String, double, double) onSugarAdded;

  const FoodSearchPage({Key? key, required this.onSugarAdded}) : super(key: key);

  @override
  _FoodSearchPageState createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {

  // Controller for search input field
  final _searchController = TextEditingController();

  // Stores search results from API
  List<Map<String, dynamic>> _searchResults = [];

  // Loading state flag
  bool _isLoading = false;

  // Function to search for food using OpenFoodFacts API
  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;

      // Clear previous results
      _searchResults = [];
    });

    try {

      // Make GET request to OpenFoodFacts API
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=1'),
      );

      if (response.statusCode == 200) {

        // Parse JSON response
        final data = json.decode(response.body);
        final List<dynamic> products = data["products"];

        // Transform API data into our format
        setState(() {
          _searchResults = products.map((product) {
            return {
              'name': product["product_name"] ?? 'Unknown',
              'sugarPer100g': product["nutriments"]["sugars_100g"] ?? 0.0,
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {

        // Reset loading state
        _isLoading = false;
      });
    }
  }

  // Function to show dialog to enter food quantity
  void _showQuantityDialog(String foodName, double sugarPer100g) {
    final quantityController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Quantity'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity (grams)',
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Consistent label color
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Quantity is required';
                    }
                    final quantity = double.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Display sugar content per 100g
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: [
                    Text(
                      'Sugar per 100g: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '     ${sugarPer100g.toStringAsFixed(2)}g',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary, // Use secondary color for the value
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align buttons to opposite ends
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {

                      // Calculate total sugar based on quantity
                      final quantity = double.parse(quantityController.text.trim());
                      final sugarContent = (sugarPer100g / 100) * quantity;

                      // Call parent callback with food details
                      widget.onSugarAdded(foodName,sugarContent, quantity);

                      // Close the dialog
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Use secondary color for button
                    foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use onSecondary color for text
                  ),
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('Search Food by Name',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40),

            // Search input field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter food name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchFood,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),

              // Search on enter key
              onSubmitted: (value) => _searchFood(),
            ),
            SizedBox(height: 20),

            // Show loading indicator or search results
            _isLoading
                ? Center(child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            )
            )
                : Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ListTile(

                    title: Text(product['name']),
                    onTap: () => _showQuantityDialog(product['name'],product['sugarPer100g']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}