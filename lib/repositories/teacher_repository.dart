import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TeacherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Fetch Teacher Profile
  Future<String> getTeacherName(String teacherId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(teacherId).get();
      if (snapshot.exists) {
        return snapshot.data()?['name'] ?? 'Teacher';
      }
      return 'Teacher';
    }
    catch (e) {
      debugPrint('Error loading teacher name: $e');
      return 'Teacher';
    }
  }

  Future<String?> startSession({
    required String teacherId,
    required DocumentSnapshot selectedClassroom,
    required List<DocumentReference> studentsList,
    required int focusMinutes,
  }) async {
    if (studentsList.isEmpty || focusMinutes <= 0) return null;

    final batch = _firestore.batch();
    final String createdAt = DateTime.now().toIso8601String();
    final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    // create study session for each student
    for (final student in studentsList) {
      final sessionRef = _firestore.collection('studySessions').doc();
      batch.set(sessionRef, {
        'createdAt': createdAt,
        'focusTime': focusMinutes,
        'isCompleted': false,
        'sessionCount': 1,
        'sessionId': sessionId,
        'studentId': student.id,
      });
    }

    await batch.commit();
    return sessionId;
  }

  Future<void> stopSession({
    required String? activeSessionId,
    required bool sessionCancelled,
    required int focusMinutes,
    required List<DocumentReference> studentsList,
  }) async {
    if (activeSessionId == null) return;

    final query = await _firestore
        .collection('studySessions')
        .where('isCompleted', isEqualTo: false)
        .where('sessionId', isEqualTo: activeSessionId)
        .get();

    final batch = _firestore.batch();

    // update sessions and increment student focus time if session was not cancelled halfway
    for (final doc in query.docs) {
      final data = doc.data();
      final studentId = data['studentId'];
      
      batch.update(doc.reference, {'isCompleted': true});

      if (sessionCancelled) {
        final studentRef = studentId is DocumentReference 
            ? studentId 
            : _firestore.collection('users').doc(studentId.toString());
            
        batch.update(studentRef, {
          'totalFocusTime': FieldValue.increment(focusMinutes),
        });
      }
    }

    await batch.commit();
  }

  Stream<QuerySnapshot> getActiveSessions() {
    return _firestore
        .collection('studySessions')
        .where('isCompleted', isEqualTo: false)
        .snapshots();
  }
  
  Future<Map<String, dynamic>> getStudentData(String studentId) async {
    final doc = await _firestore.collection('users').doc(studentId).get();
    return doc.data() as Map<String, dynamic>;
  }

  bool isStudentInClassroom(String studentPath, List<DocumentReference> studentsList) {
    return studentsList.any((ref) => ref.path == studentPath);
  }
}