import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sweet_watch/pages/personal_info_page.dart';

// RegisterPage handles user registration with email and password
class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variable for Firebase error messages
  String? _firebaseError;

  @override
  void dispose() {

    // Clean up controllers when widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to handle user registration
  Future signUp() async {


    // Validate form and check password confirmation
    if (_formKey.currentState!.validate() && passwordConfirmed() && _passwordController.text.trim().length > 6) {
      try {

        // Create user with Firebase Auth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('User registered successfully!');

        // Navigate to PersonalInfoPage after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PersonalInfoPage()),
        );

      } on FirebaseAuthException catch (e) {

        // Handle specific Firebase Auth errors
        if (e.code == 'email-already-in-use') {
          // Set the Firebase error message
          setState(() {
            _firebaseError = 'Email is already in use';
          });
          // Trigger form validation to display the error
          _formKey.currentState!.validate();
        }
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      } catch (e) {
        print('Unexpected error: $e');
      }
    }
  }

  // Function to check if the confirmation password matches with the password entered earlier
  bool passwordConfirmed() {
    return _passwordController.text.trim() == _confirmPasswordController.text.trim();
  }

  // Validate email format and check for Firebase errors
  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Email validation regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    // Check if there's a Firebase error message
    if (_firebaseError != null) {
      return _firebaseError;
    }
    return null;
  }

  // Validate password meets requirements
  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validate password confirmation matches
  String? confirmPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // App logo
                  Image.asset("images/logo.jpg",
                    width: 200,  // Set the width
                    height: 200,
                  ),
                  SizedBox(height: 30.0),

                  // Page title
                  Text(
                    'Sign up',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Email TextFormField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.error),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => emailValidator(value), // Use the validator
                      onChanged: (value) {
                        // Clear Firebase error when user edits email
                        setState(() {
                          _firebaseError = null;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Password TextFormField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.error),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: passwordValidator,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Confirm password TextFormField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _confirmPasswordController,

                      // Hide password characters
                      obscureText: true,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.error),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: confirmPasswordValidator,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Sign up button
                  Center(
                    child: ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
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

                  // log in prompt
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
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}