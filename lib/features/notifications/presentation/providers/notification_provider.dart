import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/notification_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationProvider = StreamProvider<List<NotificationModel>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.uid;

  if (userId == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  });
});

final notificationService = Provider((ref) => NotificationServiceWrapper(ref));

class NotificationServiceWrapper {
  final Ref _ref;
  NotificationServiceWrapper(this._ref);

  Future<void> markAsRead(String notificationId) async {
    final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> clearAll() async {
     final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .get();
    
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> sendTestNotification() async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendSubscriptionNotification')
          .call();
    } catch (e) {
      rethrow;
    }
  }
}

