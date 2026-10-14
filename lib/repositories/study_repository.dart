import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_sessions.dart';
import '../screens/login_page.dart';

class StudyRepository {

  // firebase collection
  final CollectionReference studyCollection =
      FirebaseFirestore.instance.collection("studySessions");

  // save study sessionto firebase
  Future<void> saveStudySession(
    StudySession session,
  ) async {
    try {
      await studyCollection.doc(session.sessionId).set(
        session.toMap(),
      );
    } catch (e) {
      print("Error saving session: $e");
    }
  }

  // get all study session from firebase
  Future<List<StudySession>> getStudySessions() async {
    try {
      QuerySnapshot snapshot =
          await studyCollection
              .where("studentId", isEqualTo: LoginPage.loggedInStudentId)
              .orderBy("createdAt", descending: true)
              .get();
      return snapshot.docs.map((doc) {
        return StudySession.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print("Error getting sessions: $e");
      return [];
    }
  }

  // delete study session from firebase
  Future<void> deleteStudySession(
    String sessionId,
  ) async {
    try {
      await studyCollection.doc(sessionId).delete();
    } catch (e) {
      print("Error deleting session: $e");
    }
  }

  Future<List<StudySession>> getStudentHistory(String studentId) async {
    try {
      QuerySnapshot snapshot = await studyCollection
          .where("studentId", isEqualTo: studentId)
          .get();

      final sessions = snapshot.docs.map((doc) {
        return StudySession.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    }
    catch (e) {
      print("Error getting student study session history: $e");
      return [];
    }
  }
}