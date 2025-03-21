import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sweet_watch/pages/login_page.dart';
import 'authentication/main_page.dart';

void main() async {
//void main(){

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyA_8IwAJF5-ZWaiFnFqnzybe-u6xMN4rFA",
        authDomain: "sweet-watch.firebaseapp.com",
        projectId: "sweet-watch",
        storageBucket: "sweet-watch.firebasestorage.app",
        messagingSenderId: "487919972592",
        appId: "1:487919972592:web:ea8c75872f2b2ff3125235"
    ));
  }else{
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
