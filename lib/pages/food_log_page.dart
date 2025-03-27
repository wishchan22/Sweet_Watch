import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'food_search_page.dart';
import 'dashboard_page.dart';

class FoodLogPage extends StatefulWidget {
  @override
  _FoodLogPageState createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  DateTime _currentDate = DateTime.now();
  List<Map<String, dynamic>> _foodLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoodLogs();
  }

  Future<void> _fetchFoodLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('food_intake')
          .where('userId', isEqualTo: user.email)
          .where('date', isEqualTo: _formatDate(_currentDate))
          .orderBy('timestamp', descending: true)
          .get();

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

  Future<void> _addFoodLog(String foodName, double sugarAmount, double servingSize) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    final newItem = {
      'userId': user.email!,
      'foodName': foodName,
      'sugarAmount': sugarAmount,
      'servingSize': servingSize,
      'timestamp': Timestamp.now(),
      'date': _formatDate(_currentDate),
    };

    try {
      await FirebaseFirestore.instance
          .collection('food_intake')
          .add(newItem);

      await _fetchFoodLogs();
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

  Future<void> _deleteFoodLog(String docId, double sugarAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      final foodDocRef = FirebaseFirestore.instance.collection('food_intake').doc(docId);
      batch.delete(foodDocRef);

      final sugarDocRef = FirebaseFirestore.instance
          .collection('consumed_sugar')
          .doc('${user.email}_${_formatDate(_currentDate)}');

      final sugarDoc = await sugarDocRef.get();
      final currentSugar = sugarDoc.exists ? (sugarDoc['consumed_sugar'] ?? 0.0).toDouble() : 0.0;

      batch.set(sugarDocRef, {
        'consumed_sugar': currentSugar - sugarAmount,
        'date': _formatDate(_currentDate),
        'userId': user.email,
      }, SetOptions(merge: true));

      await batch.commit();
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

  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
      _isLoading = true;
      _fetchFoodLogs();
    });
  }

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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _showDeleteConfirmation(String docId, double sugarAmount) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Food Entry'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
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
                    Text(
                      log['foodName'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Serving: ${log['servingSize']}g',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sugar: ${log['sugarAmount'].toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Time: $time',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            icon: Icon(Icons.list),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Trends',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodSearchPage(
                  onSugarAdded: (name, sugar, serving) {
                    _addFoodLog(name, sugar, serving);
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