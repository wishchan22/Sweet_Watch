import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sweet_watch/authentication/auth_page.dart';
import '../pages/home_page.dart';

// MainPage is a StatelessWidget that serves as the root of the application
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // StreamBuilder to listen to authentication state changes
      body: StreamBuilder<User?>(

        // Listen to Firebase auth state changes stream
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){

          // Check if the snapshot contains data (user is logged in or not)
          if(snapshot.hasData){

            // If user data exists, show the HomePage (user is logged in
            return HomePage();

          }else{

            // If no user data exists, show the AuthPage (user is not logged in)
            return AuthPage();
          }
        },
      ),
    );
  }
}

