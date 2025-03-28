import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'food_search_page.dart';
import 'dashboard_page.dart';

// FoodLogPage displays a list of food entries for the selected date
class FoodLogPage extends StatefulWidget {
  @override
  _FoodLogPageState createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {

  // State variables
  // Currently viewed date
  DateTime _currentDate = DateTime.now();

  // List of food entries
  List<Map<String, dynamic>> _foodLogs = [];

  // Loading state flag
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Load food entries when widget initializes
    _fetchFoodLogs();
  }

  // Function to fetch food logs from Firestore database for the current date
  Future<void> _fetchFoodLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isLoading = true);

    try {

      // Query food entries for current user and date, sorted by timestamp
      final querySnapshot = await FirebaseFirestore.instance
          .collection('food_intake')
          .where('userId', isEqualTo: user.email)
          .where('date', isEqualTo: _formatDate(_currentDate))
          .orderBy('timestamp', descending: true)
          .get();

      // Transform documents into list of food log maps
      setState(() {
        _foodLogs = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'userId': data['userId'],
            'foodName': data['foodName'] ?? 'Unknown',
            'sugarAmount': (data['sugarAmount'] ?? 0.0).toDouble(),
            'servingSize': (data['servingSize'] ?? 0.0).toDouble(),
            'timestamp': data['timestamp'],
            'date': data['date'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching food logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  //Function to add a new food entry to Firestore database
  Future<void> _addFoodLog(String foodName, double sugarAmount, double servingSize) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {

      // Use batch write for atomic updates
      final batch = FirebaseFirestore.instance.batch();

      // Add to food_intake collection
      final foodDocRef = FirebaseFirestore.instance.collection('food_intake').doc();
      batch.set(foodDocRef, {
        'userId': user.email!,
        'foodName': foodName,
        'sugarAmount': sugarAmount,
        'servingSize': servingSize,
        'timestamp': Timestamp.now(),
        'date': _formatDate(_currentDate),
      });

      // Update consumed_sugar collection
      final sugarDocRef = FirebaseFirestore.instance
          .collection('consumed_sugar')
          .doc('${user.email}_${_formatDate(_currentDate)}');

      // Get current sugar value
      final sugarDoc = await sugarDocRef.get();
      final currentSugar = sugarDoc.exists ? (sugarDoc['consumed_sugar'] ?? 0.0).toDouble() : 0.0;

      // Update with new total
      batch.set(sugarDocRef, {
        'consumed_sugar': currentSugar + sugarAmount,
        'date': _formatDate(_currentDate),
        'userId': user.email,
      }, SetOptions(merge: true));

      // Execute both operations atomically
      await batch.commit();

      // Refresh the food log list
      await _fetchFoodLogs();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$foodName added successfully!')),
      );
    } catch (e) {
      print('Error adding food log: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add food: ${e.toString()}')),
      );
    }
  }


  // Function to delete a food entry from Firestore firebase
  Future<void> _deleteFoodLog(String docId, double sugarAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {

      // Use batch write for atomic updates
      final batch = FirebaseFirestore.instance.batch();

      // Delete food entry
      final foodDocRef = FirebaseFirestore.instance.collection('food_intake').doc(docId);
      batch.delete(foodDocRef);

      // Update consumed_sugar collection
      final sugarDocRef = FirebaseFirestore.instance
          .collection('consumed_sugar')
          .doc('${user.email}_${_formatDate(_currentDate)}');

      // Get current sugar value
      final sugarDoc = await sugarDocRef.get();
      final currentSugar = sugarDoc.exists ? (sugarDoc['consumed_sugar'] ?? 0.0).toDouble() : 0.0;

      // Update with reduced total
      batch.set(sugarDocRef, {
        'consumed_sugar': currentSugar - sugarAmount,
        'date': _formatDate(_currentDate),
        'userId': user.email,
      }, SetOptions(merge: true));

      // Execute both operations atomically
      await batch.commit();

      // Refresh the list
      await _fetchFoodLogs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food item deleted successfully')),
      );
    } catch (e) {
      print('Error deleting food log: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  // Function to Navigate to previous day
  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
      _isLoading = true;
      _fetchFoodLogs();
    });
  }

  // Function to navigate to next day when in past dates
  void _goToNextDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_currentDate.isBefore(today)) {
      setState(() {
        _currentDate = _currentDate.add(Duration(days: 1));
        _isLoading = true;
        _fetchFoodLogs();
      });
    }
  }

  // Format date as yyyy-MM-dd string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to show confirmation dialog before deleting food entry
  Future<void> _showDeleteConfirmation(String docId, double sugarAmount) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: Text('Delete Food Entry'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteFoodLog(docId, sugarAmount);
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _goToPreviousDay,
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(_currentDate),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _currentDate.isBefore(DateTime.now()) ? _goToNextDay : null,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _foodLogs.isEmpty
          ? Center(
        child: Text(
          'No food logs for this day.\nAdd some food to get started!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(

        // List of food entries
        itemCount: _foodLogs.length,
        itemBuilder: (context, index) {
          final log = _foodLogs[index];
          final timestamp = (log['timestamp'] as Timestamp).toDate();
          final time = DateFormat('HH:mm').format(timestamp);

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Food name
                    Text(
                      log['foodName'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Serving size
                    Text(
                      'Serving: ${log['servingSize']}g',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 4),

                    // Time consumed
                    Text(
                      'Time: $time',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 4),

                    // Sugar amount
                    Text(
                      'Sugar: ${log['sugarAmount'].toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),

                // Delete button
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed: () => _showDeleteConfirmation(log['id'], log['sugarAmount']),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          );
        },
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(

        // Log page is active
        currentIndex: 2,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Log',
          ),

        ],
        onTap: (index) {
          if (index == 0) {

            // Navigate to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          } else if (index == 1) {

            // Navigate to Add Food page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodSearchPage(
                  onSugarAdded: (name, sugar, serving) async {
                    await _addFoodLog(name, sugar, serving);
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}