import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final DateTime createdAt;
  final String feedbackMessage;
  final String studentID;
  final String teacherID;

  Feedback({
    required this.createdAt,
    required this.feedbackMessage,
    required this.studentID,
    required this.teacherID,
  });

  factory Feedback.fromMap(Map<String, dynamic> map, {String? id}) {
    return Feedback(
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      feedbackMessage: map['feedbackMessage'] ?? '',
      studentID: map['studentID'] ?? '',
      teacherID: map['teacherID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'feedbackMessage': feedbackMessage,
      'studentID': studentID,
      'teacherID': teacherID,
    };
  }
}