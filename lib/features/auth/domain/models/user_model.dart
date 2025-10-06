import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String? role; // Add role field

  UserModel({
    required this.uid,
    required this.email,
    this.role,
  });

  factory UserModel.fromFirebase(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: null, // Role will be fetched separately
    );
  }

  UserModel copyWith({String? uid, String? email, String? role}) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}