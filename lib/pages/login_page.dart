import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF2F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
            
                SizedBox(height: 230.0),
            
                Text(
                  'Sign in',
                  style: TextStyle(
                    color: Color(0xFF2D336B), // Primary color
                    fontSize: 24.0, // Title size
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
                SizedBox(height: 30),
            
                //Email textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF2F2),
                      border: Border.all(color: Color(0xFF2D336B)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _emailController,
                        style: TextStyle(color: Color(0xFF2D336B)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Email', // Optional placeholder
                          hintStyle: TextStyle(color: Color(0xFFA9B5DF)),
                        ),
                      ),
                    ),
                  ),
                ),
            
                SizedBox(height: 20),
            
                //Password textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF2F2),
                      border: Border.all(color: Color(0xFF2D336B)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: Color(0xFF2D336B)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Password', // Optional placeholder
                          hintStyle: TextStyle(color: Color(0xFFA9B5DF)),
                        ),
                      ),
                    ),
                  ),
                ),
            
                SizedBox(height: 20),
            
                Center(
                  child: ElevatedButton(
                    onPressed: () async {

                      signIn();
            
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2D336B), // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            
                SizedBox(height: 30),
            
                // not a member, register option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        ' Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                                  
                        ),
                      ),
                    ),
            
                  ],
                )
            
            
            ],
            ),
          ),
        ),

      ),
    );
  }
}
