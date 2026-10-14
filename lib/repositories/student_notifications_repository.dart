import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNotificationsRepository {

  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection(
        "notifications",
      );

  // add notification
  Future<void> addNotification({
    required String title,
    required String message,
  }) async {
    await notificationsCollection.add({
      "title": title,
      "message": message,
      "createdAt": DateTime.now(),
    });
  }

  // delete notification
  Future<void> deleteNotification(
    String docId,
  ) async {
    await notificationsCollection
        .doc(docId)
        .delete();
  }
}