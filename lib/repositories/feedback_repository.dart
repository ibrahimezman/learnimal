import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback.dart';

class FeedbackRepository {
  final CollectionReference feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');

  Future<void> addFeedback(Feedback feedback) async {
    await feedbackCollection.add(feedback.toMap());
  }

  Future<List<Feedback>> getAllFeedback() async {
    final snapshot = await feedbackCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      return Feedback.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }).toList();
  }

  Stream<List<Feedback>> streamFeedback() {
    return feedbackCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Feedback.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    });
  }

  Future<void> deleteFeedback(String id) async {
    await feedbackCollection.doc(id).delete();
  }
}