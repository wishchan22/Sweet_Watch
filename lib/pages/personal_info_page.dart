import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';
class PersonalInfoPage extends StatefulWidget {

  const PersonalInfoPage({super.key});
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String gender = 'female'; // Default gender


  // Function to save personal info to Firestore
  Future<void> savePersonalInfo(String name, int age, double height, double weight, String gender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email; // Use email as the document ID
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender,
      });

      // Navigate to DashboardPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }
  }

  void next () async {
    if (_formKey.currentState!.validate()){
      print('next done');
      // Get the values from the text fields
      String name = _nameController.text;
      int age = int.parse(_ageController.text);
      double height = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);

      // Save personal info to Firestore
      await savePersonalInfo(name, age, height, weight, gender);

    }
  }




  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String? nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  // Age validator
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

  // Height validator
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

  // Weight validator
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
                  SizedBox(height: 50),
                  Text(
                    'Please Enter Your Personal Info',
                    style: TextStyle(color: colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Name textFormField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
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

                  // Age TextField

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _ageController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
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

                  // Weight textfield

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _weightController,
                      style: TextStyle(color: colorScheme.primary),
                      decoration: InputDecoration(
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

                  ElevatedButton(
                    onPressed: next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Button color
                      foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Button padding
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