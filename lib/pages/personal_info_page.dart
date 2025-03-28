import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';

// PersonalInfoPage is a StatefulWidget that collects user's personal information
class PersonalInfoPage extends StatefulWidget {

  const PersonalInfoPage({super.key});
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String gender = 'female'; // Default gender


  // Function to save personal info to Firestore database
  Future<void> savePersonalInfo(String name, int age, double height, double weight, String gender) async {

    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      // Use email as the document ID
      final email = user.email;

      // Save data to Firestore database under 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender,
      });

      // Navigate to DashboardPage after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }
  }

  // Function called when Next button is pressed
  void goToRegisterPage () async {
    if (_formKey.currentState!.validate()){
      print('next done');

      // Get the values from the text fields
      String name = _nameController.text;
      int age = int.parse(_ageController.text);
      double height = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);

      // Save personal info to Firestore database
      await savePersonalInfo(name, age, height, weight, gender);

    }
  }




  @override
  void dispose() {

    // Clean up controllers when widget is disposed
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Validator for name field
  String? nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  // Validator for age field
  String? ageValidator(String? value) {
    if (value == null || value.trim().isEmpty || int.tryParse(value) == null) {
      return 'Please enter a valid number for age';
    }

    final age = int.parse(value);
    if (age < 5 || age > 90) {
      return 'Age must be between 5 and 90';
    }

    return null;
  }

  // Validator for height field
  String? heightValidator(String? value) {
    if (value == null || value.trim().isEmpty || double.tryParse(value) == null) {
      return 'Please enter a valid number for height';
    }

    final height = double.parse(value);
    if (height < 100 || height > 200) {
      return 'Height must be between 100cm and 200cm';
    }

    return null;
  }

  // Validator for weight field
  String? weightValidator(String? value) {
    if (value == null || value.trim().isEmpty || double.tryParse(value) == null) {
      return 'Please enter a valid number for weight';
    }

    final weight = double.parse(value);
    if (weight < 15 || weight > 200) {
      return 'Weight must be between 15kg and 200kg';
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {

    // Fetch colors from theme
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

                  Image.asset("images/logo.jpg",
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 50),
                  Text(
                    'Please Enter Your Personal Info',
                    style: TextStyle(color: colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Name TextFormField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Name',
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
                        //errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      validator: nameValidator,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Age TextFormField

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _ageController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.calendar_today_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Age',
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
                        hintText: 'Enter Age (5 - 95)',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                        //errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      validator: ageValidator,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Height TextFormField

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _heightController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.height_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Height',
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
                        hintText: 'Enter Height (100cm - 200cm)',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                        //errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      validator: heightValidator,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Weight TextFormField

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _weightController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.scale_outlined,
                          color: colorScheme.secondary,
                        ),
                        labelText: 'Weight',
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
                        hintText: 'Enter Weight (15kg - 200kg)',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                        //errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      validator: weightValidator,
                    ),
                  ),


                  SizedBox(height: 20),

                  // Gender Selection (Radio Buttons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            // Female option
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'female',
                                  groupValue: gender,
                                  onChanged: (String? value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                  activeColor: colorScheme.secondary,
                                ),
                                Text('Female', style: TextStyle(color: colorScheme.onSurface)),
                              ],
                            ),

                            // Male option
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'male',
                                  groupValue: gender,
                                  onChanged: (String? value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                  activeColor: colorScheme.secondary,
                                ),
                                Text('Male', style: TextStyle(color: colorScheme.onSurface)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Next button
                  ElevatedButton(
                    onPressed: goToRegisterPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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