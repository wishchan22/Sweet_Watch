import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {

  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if(passwordConfired()){
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );
    }

  }

  bool passwordConfired(){
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    }else{
      return false;
    }
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
                  'Sign up',
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

                // Confirm password textfield
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: Color(0xFF2D336B)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Confirm Password', // Optional placeholder
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

                      signUp();

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
                      'Sign up',
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
                      'I am a member!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Login now',
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
