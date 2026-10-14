import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_page.dart';

class GoalsRepository {
  final CollectionReference goalsCollection = FirebaseFirestore.instance
      .collection("goals");

  // add goal
  Future<void> addGoal({
    required String goal,
    required String time,
    required bool isDone,
  }) async {
    await goalsCollection.add({
      "studentId": LoginPage.loggedInStudentId,
      "goal": goal,
      "time": time,
      "isDone": isDone,
      "createdAt": DateTime.now(),
    });
  }

  // update goal status
  Future<void> updateGoalStatus({
    required String docId,
    required bool isDone,
  }) async {
    await goalsCollection.doc(docId).update({"isDone": isDone});
  }

  // delete goal
  Future<void> deleteGoal(String docId) async {
    await goalsCollection.doc(docId).delete();
  }
}
