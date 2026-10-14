import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getStudent(String studentId) async {
    return await _firestore.collection('users').doc(studentId).get();
  }

  List<DocumentReference> getStudentsList(List<String> studentIds) {
    return studentIds
        .map((id) => _firestore.collection('users').doc(id))
        .toList();
  }

  Stream<QuerySnapshot> getAllStudents() {
    return _firestore.collection('users')
    .where('role', isEqualTo: 'Student')
    .snapshots();
  }
}