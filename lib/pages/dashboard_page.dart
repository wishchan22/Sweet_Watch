import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sweet_watch/pages/food_log_page.dart';
import 'package:sweet_watch/pages/profile_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_search_page.dart';
import 'package:intl/intl.dart';
import 'package:sweet_watch/services/user_service.dart';


// DashboardPage is the main screen showing sugar consumption data
class DashboardPage extends StatefulWidget {

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  // Service for user data operations
  final UserService _userService = UserService();

  // State variables
  // Currently viewed date
  DateTime _currentDate = DateTime.now();

  // Maximum allowed sugar per day
  double _allowedSugarIntake = 0.0;

  // Current sugar consumption
  double _consumedSugar = 0.0;

  // Stream subscriptions for real-time updates
  // For sugar consumption data
  StreamSubscription? _sugarSubscription;

  // For user profile data
  StreamSubscription? _userSubscription;


  @override
  void initState() {
    super.initState();

    // Initialize data listeners when widget loads
    _setupDataListener();

  }

  // Function to set up Firebase data listeners
  void _setupDataListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {

      // Listen for user data changes
      _userSubscription = _userService.getUserStream(user.email!)
          .listen((_) => _fetchUserDataAndCalculateSugar());

      // Listen for sugar consumption changes for current date
      _sugarSubscription = FirebaseFirestore.instance
          .collection('consumed_sugar')
          .doc('${user.email}_${_currentDate.toIso8601String().split('T')[0]}')
          .snapshots()
          .listen((doc) {
        if (mounted) {
          setState(() {
            _consumedSugar = doc.exists ? (doc['consumed_sugar'] ?? 0.0).toDouble() : 0.0;
          });
        }
      });
    }
  }

  // Function to fetch user data and calculate allowed sugar intake
  Future<void> _fetchUserDataAndCalculateSugar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final doc = await _userService.getUserStream(user.email!).first;
      if (doc.exists) {
        setState(() {
          _allowedSugarIntake = _calculateAllowedSugar(
            doc['age'] ?? 0,
            (doc['weight'] ?? 0.0).toDouble(),
            (doc['height'] ?? 0.0).toDouble(),
            doc['gender'] ?? 'Male',
          );
        });
      }
    }
  }

  // Function to navigate to profile page
  void _navigateToProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    // Set up a one-time listener for changes
    final userDoc = _userService.getUserStream(user.email!).take(1);

    // Navigate to profile
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          onProfileUpdated: _fetchUserDataAndCalculateSugar,
        ),
      ),
    );

    // Check for updates after returning
    userDoc.listen((_) => _fetchUserDataAndCalculateSugar());
  }

  @override
  void dispose() {

    // Clean up subscriptions
    _userSubscription?.cancel();
    _sugarSubscription?.cancel();
    super.dispose();
  }

  // Callback function to update consumed sugar
  Future<void> _updateConsumedSugar(String foodName, double sugarAmount, double servingSize) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      // Create a batch write to update both collections atomically
      final batch = FirebaseFirestore.instance.batch();

      //Add to food_intake collection
      final foodDocRef = FirebaseFirestore.instance.collection('food_intake').doc();
      batch.set(foodDocRef, {
        'userId': user.email,
        'foodName': foodName,
        'sugarAmount': sugarAmount,
        'servingSize': servingSize,
        'timestamp': Timestamp.now(),
        'date': _currentDate.toIso8601String().split('T')[0],
      });

      //Update the consumed_sugar document
      final sugarDocRef = FirebaseFirestore.instance
          .collection('consumed_sugar')
          .doc('${user.email}_${_currentDate.toIso8601String().split('T')[0]}');

      final sugarDoc = await sugarDocRef.get();
      final currentSugar = sugarDoc.exists ? (sugarDoc['consumed_sugar'] ?? 0.0).toDouble() : 0.0;

      batch.set(sugarDocRef, {
        'consumed_sugar': currentSugar + sugarAmount,
        'date': _currentDate.toIso8601String().split('T')[0],
        'userId': user.email,
      }, SetOptions(merge: true));

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$foodName added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: ${e.toString()}')),
      );
    }
  }


  // Function to calculate allowed daily sugar based on user metrics
  double _calculateAllowedSugar(int age, double weight, double height, String gender) {
    double bmr;

    if (gender.toLowerCase() == 'female') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    }

    // Fixed moderate activity level (TDEE = BMR * 1.55)
    double tdee = bmr * 1.55;

    // Calculate sugar intake (WHO: max 10% of daily calories, ideal 5%)
    double maxSugar = (tdee * 0.10) / 4;  // Convert kcal to grams

    return double.parse(maxSugar.toStringAsFixed(2));

  }

  // Function to Navigate to previous day
  void _goToPreviousDay() {
    _sugarSubscription?.cancel();
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
      _consumedSugar = 0.0;
    });
    _setupDataListener();
  }

  // Function to navigate to next day when in past dates
  void _goToNextDay() {
    final currentDateMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (_currentDate.isBefore(currentDateMidnight)) {
      _sugarSubscription?.cancel();
      setState(() {
        _currentDate = _currentDate.add(Duration(days: 1));
        _consumedSugar = 0.0;
      });
      _setupDataListener();

    }
  }

  // Format date as yyyy-MM-dd string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Fetch colors from theme
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate remaining sugar and check if over limit
    final double remainingSugar = _allowedSugarIntake - _consumedSugar;
    final bool isOverLimit = remainingSugar < 0;

    // Data for the doughnut chart
    List<double> chartData = [
      _consumedSugar,
      remainingSugar >= 0 ? remainingSugar : 0,
    ];

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
              //'${_currentDate.day}/${_currentDate.month}/${_currentDate.year}',
              DateFormat('dd/MM/yyyy').format(_currentDate),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _currentDate.isBefore(DateTime.now()) ? _goToNextDay : null,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 70),
              Text(
                'Daily Sugar Tracker (in grams)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
          
                    // Doughnut chart showing sugar consumption
                    SfCircularChart(
                      series: <CircularSeries>[
                        DoughnutSeries<double, String>(
                          dataSource: chartData,
                          xValueMapper: (double data, _) => '',
                          yValueMapper: (double data, _) => data,
                          pointColorMapper: (double data, int index) =>
                          index == 0 ? colorScheme.secondary : colorScheme.primary,
                          radius: '80%',
                          innerRadius: '70%',
                        ),
                      ],
                    ),
          
                    // Center text showing remaining/over sugar
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isOverLimit
                              ? '${remainingSugar.abs().toStringAsFixed(2)}'
                              : remainingSugar.toStringAsFixed(2),
          
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
          
          
                        Text(
                          isOverLimit ? 'Over' : 'Left',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isOverLimit
                                ? colorScheme.error
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Total budget for sugar intake per day = ${_allowedSugarIntake.toStringAsFixed(2)}g',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Consumed sugar level = ${_consumedSugar.toStringAsFixed(2)}g',
                style: TextStyle(color: colorScheme.secondary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
          
            ],
          ),
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(

        // Dashboard is active
        currentIndex: 0,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodSearchPage(
                  onSugarAdded: (name, sugar, serving) async {
                    await _updateConsumedSugar(name, sugar, serving);
                  },
                ),
              ),
            );
          }
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodLogPage(),
              ),
            );
          }
        },
      ),
    );
  }
}


