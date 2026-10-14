import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  // firestore collections
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection("users");

  final CollectionReference subjectsCollection = FirebaseFirestore.instance
      .collection("subjects");

  final CollectionReference studySessionsCollection = FirebaseFirestore.instance
      .collection("studySessions");

  // get users real-time stream
  Stream<QuerySnapshot> getUsersStream() {
    return usersCollection.snapshots();
  }

  // add new user to database
  Future<void> addUser({
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      await usersCollection.add({
        "name": name,
        "email": email.trim().toLowerCase(),
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  // update user details
  Future<void> updateUser({
    required String docId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      await usersCollection.doc(docId).update({
        "name": name,
        "email": email.trim().toLowerCase(),
        "role": role,
      });
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // delete user from firestore
  Future<void> deleteUser(String docId) async {
    try {
      await usersCollection.doc(docId).delete();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  // get user role by email
  Future<String> getUserRole(String email) async {
    try {
      QuerySnapshot query = await usersCollection
          .where("email", isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        return data["role"] ?? "Student";
      }
    } catch (e) {
      print("Error getting role: $e");
    }
    return "Student";
  }

  // get subjects real-time stream
  Stream<QuerySnapshot> getSubjectsStream() {
    return subjectsCollection.orderBy("code").snapshots();
  }

  // add new subject
  Future<void> addSubject({required String name, required String code}) async {
    try {
      await subjectsCollection.add({
        "name": name,
        "code": code.trim().toUpperCase(),
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding subject: $e");
    }
  }

  // update subject details
  Future<void> updateSubject({
    required String docId,
    required String name,
    required String code,
  }) async {
    try {
      await subjectsCollection.doc(docId).update({
        "name": name,
        "code": code.trim().toUpperCase(),
      });
    } catch (e) {
      print("Error updating subject: $e");
    }
  }

  // delete subject from firestore
  Future<void> deleteSubject(String docId) async {
    try {
      await subjectsCollection.doc(docId).delete();
    } catch (e) {
      print("Error deleting subject: $e");
    }
  }

  // get study sessions for stats
  Future<QuerySnapshot> getStudySessions() async {
    return await studySessionsCollection.get();
  }
}
