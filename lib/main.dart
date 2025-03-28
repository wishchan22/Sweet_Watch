import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'authentication/main_page.dart';


void main() async {

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF2D336B), // Deep blue
          onPrimary: Color(0xFFFFFFFF),
          //secondary: Color(0xFF56B870),
          secondary: Color(0xFF9C89B8),
          onSecondary: Color(0xFFFFFFFF),
          error: Color(0xFFD32F2F),
          onError: Color(0xFFFFFFFF),
          //surface: Color(0xFFFFF2F2),
          surface: Color(0xFFE0F2F0),
          onSurface: Color(0xFF2D336B),
        ),
      ),

    );


  }
}
