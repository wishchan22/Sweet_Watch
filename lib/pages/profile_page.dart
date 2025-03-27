import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sweet_watch/authentication/auth_page.dart';
import 'package:sweet_watch/pages/login_page.dart';
import 'package:sweet_watch/pages/register_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfilePage({Key? key, this.onProfileUpdated}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _name;
  late int _age;
  late double _height;
  late double _weight;
  late String _email;
  late String _gender;

  bool _isEditingName = false;
  bool _isEditingAge = false;
  bool _isEditingHeight = false;
  bool _isEditingWeight = false;
  bool _isEditingGender = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.email).get();

      if (userDoc.exists) {
        setState(() {
          _name = userDoc['name'] ?? 'Not set';
          _age = userDoc['age'] ?? 0;
          _height = userDoc['height']?.toDouble() ?? 0.0;
          _weight = userDoc['weight']?.toDouble() ?? 0.0;
          _email = user.email ?? 'No email';
          _gender = userDoc['gender'] ?? 'male';

          _nameController.text = _name;
          _ageController.text = _age.toString();
          _heightController.text = _height.toString();
          _weightController.text = _weight.toString();

          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog(String fieldName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update $fieldName'),
        content: Text('Changing your $fieldName will update your daily sugar intake recommendation. Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _updateUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.email).update({
          'name': _name,
          'age': _age,
          'height': _height,
          'weight': _weight,
          'gender': _gender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem(
              'Email',
              Text(_email),
              null,
            ),
            Divider(),
            _buildProfileItem(
              'Name',
              _isEditingName ? _buildTextField(_nameController, (value) => _name = value) : Text(_name),
                  () async {
                if (_isEditingName) {
                  setState(() {
                    _name = _nameController.text;
                    _updateUserData();
                  });
                }
                setState(() => _isEditingName = !_isEditingName);
              },
            ),
            Divider(),
            _buildProfileItem(
              'Age',
              _isEditingAge ? _buildTextField(_ageController, (value) => _age = int.tryParse(value) ?? _age) : Text('$_age years'),
                  () async {
                if (_isEditingAge) {
                  final confirmed = await _showConfirmationDialog('age');
                  if (confirmed) {
                    setState(() {
                      _age = int.tryParse(_ageController.text) ?? _age;
                      _updateUserData();
                    });
                  }
                }
                setState(() => _isEditingAge = !_isEditingAge);
              },
            ),
            Divider(),
            _buildProfileItem(
              'Height',
              _isEditingHeight ? _buildTextField(_heightController, (value) => _height = double.tryParse(value) ?? _height) : Text('${_height.toStringAsFixed(1)} cm'),
                  () async {
                if (_isEditingHeight) {
                  final confirmed = await _showConfirmationDialog('height');
                  if (confirmed) {
                    setState(() {
                      _height = double.tryParse(_heightController.text) ?? _height;
                      _updateUserData();
                    });
                  }
                }
                setState(() => _isEditingHeight = !_isEditingHeight);
              },
            ),
            Divider(),
            _buildProfileItem(
              'Weight',
              _isEditingWeight ? _buildTextField(_weightController, (value) => _weight = double.tryParse(value) ?? _weight) : Text('${_weight.toStringAsFixed(1)} kg'),
                  () async {
                if (_isEditingWeight) {
                  final confirmed = await _showConfirmationDialog('weight');
                  if (confirmed) {
                    setState(() {
                      _weight = double.tryParse(_weightController.text) ?? _weight;
                      _updateUserData();
                    });
                  }
                }
                setState(() => _isEditingWeight = !_isEditingWeight);
              },
            ),
            Divider(),
            _buildProfileItem(
              'Gender',
              _isEditingGender
                  ? DropdownButton<String>(
                value: _gender,
                items: ['male', 'female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    final confirmed = await _showConfirmationDialog('gender');
                    if (confirmed) {
                      setState(() {
                        _gender = newValue;
                        _updateUserData();
                        _isEditingGender = false;
                      });
                    }
                  }
                },
              )
                  : Text(_gender),
                  () {
                setState(() => _isEditingGender = !_isEditingGender);
              },
            ),
            Divider(),

            SizedBox(height: 55),

            Center( // Centering the button
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => AuthPage(), // Navigate to AuthPage instead of LoginPage
                      ),
                          (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not sign out: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Button color
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),




          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, Widget valueWidget, VoidCallback? onEditPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: valueWidget,
          ),
          if (onEditPressed != null)
            IconButton(
              icon: Icon(
                _getEditIcon(label),
                size: 20,
              ),
              onPressed: onEditPressed,
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, Function(String) onChanged) {
    return TextField(
      controller: controller,
      keyboardType: controller == _nameController
          ? TextInputType.text
          : TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      onChanged: onChanged,
    );
  }

  IconData _getEditIcon(String label) {
    if (label == 'Name' && _isEditingName) return Icons.check;
    if (label == 'Age' && _isEditingAge) return Icons.check;
    if (label == 'Height' && _isEditingHeight) return Icons.check;
    if (label == 'Weight' && _isEditingWeight) return Icons.check;
    if (label == 'Gender' && _isEditingGender) return Icons.check;
    return Icons.edit;
  }
}