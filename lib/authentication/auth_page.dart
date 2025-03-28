import 'package:flutter/material.dart';
import 'package:sweet_watch/pages/login_page.dart';

import '../pages/register_page.dart';

// AuthPage is a StatefulWidget that handles switching between Login and Register pages
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // Boolean flag to determine which page to show
  // Initially set to true to show the LoginPage first
  bool showLoginPage = true;

  // Function to toggle between Login and Register pages
  void toggleScreens(){
    setState(() {

      // Flip the boolean value to switch between pages
      showLoginPage = !showLoginPage;
    });

  }
  @override
  Widget build(BuildContext context) {

    // Conditional rendering based on showLoginPage flag
    if(showLoginPage){

      // Show LoginPage and pass the toggle function to switch to RegisterPage
      return LoginPage(showRegisterPage: toggleScreens);
    }else{

      // Show RegisterPage and pass the toggle function to switch back to LoginPage
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
