import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sweet_watch/authentication/auth_page.dart';
import 'package:sweet_watch/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return HomePage();

          }else{
            return AuthPage();
          }
        },
      ),
    );
  }
}
