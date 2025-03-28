import 'package:flutter/material.dart';
import 'dashboard_page.dart';

// HomePage is a StatefulWidget that serves as the main container for the app
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Display the DashboardPage as the main content
      body: DashboardPage(),
    );
  }
}
