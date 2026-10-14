class StudySession {
  final String sessionId;
  final String studentId;
  final int focusTime;
  final int sessionCount;
  final DateTime createdAt;
  final bool isCompleted;

  // constructor
  StudySession({
    required this.sessionId,
    required this.studentId,
    required this.focusTime,
    required this.sessionCount,
    required this.createdAt,
    required this.isCompleted,
  });

  // for firebase -> convert to map format for firebase to store
  Map<String, dynamic> toMap() {
    return {
      "sessionId": sessionId,
      "studentId": studentId,
      "focusTime": focusTime,
      "sessionCount": sessionCount,
      "createdAt": createdAt.toIso8601String(),
      "isCompleted": isCompleted,
    };
  }

  // convert from firebase map
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      sessionId: map["sessionId"] ?? "",
      studentId: map["studentId"] ?? "",
      focusTime: map["focusTime"] ?? 0,
      sessionCount: map["sessionCount"] ?? 0,
      createdAt: DateTime.parse(
        map["createdAt"],
      ),
      isCompleted: map["isCompleted"] ?? false,
    );
  }
}