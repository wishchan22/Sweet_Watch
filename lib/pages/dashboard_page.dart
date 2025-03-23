import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _currentDate = DateTime.now();
  double _allowedSugarIntake = 0.0; // Example value for allowed sugar intake
  double _consumedSugar = 10.0; // Example value for consumed sugar
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndCalculateSugar();
  }

  Future<void> _fetchUserDataAndCalculateSugar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email;
      final doc = await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final age = data['age'] as int;
        final weight = data['weight'] as double;
        final height = data['height'] as double; // Ensure height is stored in cm
        final gender = data['gender'] as String;

        // Calculate allowed sugar based on gender, height, weight, and age
        setState(() {
          //_allowedSugarIntake = _calculateAllowedSugar(age, weight, height, gender);
          _allowedSugarIntake = double.parse(_calculateAllowedSugar(age, weight, height, gender).toStringAsFixed(2));
          _isLoading = false;
        });
      }
    }
  }

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
    double idealSugar = (tdee * 0.05) / 4;

    return maxSugar; // Return max allowed sugar intake (modify if you want ideal)
  }



  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
    });
  }


  void _goToNextDay() {
    final currentDateMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (_currentDate.isBefore(currentDateMidnight)) {
      setState(() {
        _currentDate = _currentDate.add(Duration(days: 1));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Fetch colors from theme
    final colorScheme = Theme.of(context).colorScheme;

    final double remainingSugar = _allowedSugarIntake - _consumedSugar;
    final bool isOverLimit = remainingSugar < 0;
    final String chartCenterText = isOverLimit
        ? '${remainingSugar.abs().toStringAsFixed(2)}g over'
        : '${remainingSugar.toStringAsFixed(2)}g left';

    // Pie chart data (ensure total adds up to the allowed sugar intake)
    List<double> chartData = [
      _consumedSugar, // Consumed Sugar (Secondary Color)
      remainingSugar >= 0 ? remainingSugar : 0, // Remaining Sugar (Primary Color)
    ];

    return Scaffold(
      appBar: AppBar(

        backgroundColor: colorScheme.primary,  // Primary color for AppBar
        foregroundColor: colorScheme.onPrimary,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _goToPreviousDay,
            ),
            Text(
              '${_currentDate.day}/${_currentDate.month}/${_currentDate.year}',
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
            onPressed: () {
              // Navigate to profile page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Text(
              'Daily Sugar Tracker (in grams)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 300, // Height for the chart container
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isOverLimit
                            ? '${remainingSugar.abs().toStringAsFixed(2)}' // Show negative value for over
                            : remainingSugar.toStringAsFixed(2),
                        //remainingSugar.toStringAsFixed(1), // Display remaining sugar
                        style: TextStyle(
                          fontSize: 32, // Larger font size for the number
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),


                      Text(
                        isOverLimit ? 'Over' : 'Left',
                        style: TextStyle(
                          fontSize: 18, // Smaller font size for the label
                          fontWeight: FontWeight.bold,
                          color: isOverLimit
                              ? Colors.red // Red for over
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
              'Total budget for sugar intake per day = $_allowedSugarIntake g',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: colorScheme.surface, // Use surface color from the theme
        selectedItemColor: colorScheme.secondary, // Color for selected item
        unselectedItemColor: colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
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
          // Handle navigation
        },
      ),
    );
  }
}