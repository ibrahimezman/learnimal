import 'package:cloud_firestore/cloud_firestore.dart';

class RewardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> giftReward({
    required String studentId,
    required String teacherId,
    required int amount,
    required String note,
  }) async {
    try {
      final batch = _firestore.batch();
      final users = _firestore.collection('users').doc(studentId);
      
      batch.update(users, {
        'coins': FieldValue.increment(amount),
      });

      final rewardHistory = _firestore.collection('rewardHistory').doc();
      batch.set(rewardHistory, {
        'studentId': studentId,
        'teacherId': teacherId,
        'amount': amount,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    }
    catch (e) {
      print("Error executing gift transaction batch: $e");
      return false;
    }
  }
}