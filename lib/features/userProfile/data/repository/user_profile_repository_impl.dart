import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../order/data/models/user_model.dart';
import '../../domain/repository/user_profile_repository.dart';

class AllUserProfileRepositorImpl implements AllUserProfileRepository {
  final FirebaseFirestore _firestore;

  AllUserProfileRepositorImpl(this._firestore);

  @override
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
