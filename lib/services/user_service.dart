import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getUserStream(String email) {
    return _firestore.collection('users').doc(email).snapshots();
  }

  Future<void> updateUserData({
    required String email,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String gender,
  }) async {
    await _firestore.collection('users').doc(email).update({
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
    });
  }
}