import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classrooms.dart';

class ClassroomRepository {

  final CollectionReference classrooms = FirebaseFirestore.instance.collection("classrooms");

  Future<List<Classroom>> getClassrooms() async {
    try {
      QuerySnapshot snapshot =
          await classrooms
              .orderBy("title", descending: false)
              .get();
      return snapshot.docs.map((doc) {
        return Classroom.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print("Error getting classrooms: $e");
      return [];
    }
  }

  Future<void> deleteClassroom(
    String code,
  ) async {
    try {
      await classrooms.doc(code).delete();
    }
    catch (e) {
      print("Error deleting classroom: $e");
    }
  }

  Future<List<Map<String, String>>> loadClassroomStudents(String teacherId) async {
    try {
      final getTeacherClassrooms = await FirebaseFirestore.instance
          .collection('classrooms')
          .where('teacher', isEqualTo: teacherId)
          .get();

      if (getTeacherClassrooms.docs.isEmpty) return [];

      final classroomData = getTeacherClassrooms.docs.first.data();
      final studentIds = (classroomData['students'] as List<dynamic>? ?? [])
          .map((id) => id.toString())
          .toList();

      final students = <Map<String, String>>[];

      for (final id in studentIds) {
        final student = await FirebaseFirestore.instance.collection('users').doc(id).get();
        if (student.exists) {
          final data = student.data();

          students.add({
            'id': student.id,
            'name': data?['name'] ?? 'Student',
          });
        }
      }
      
      return students;
    }
    catch (e) {
      print("Error loading classroom students: $e");
      return [];
    }
  }
}