class Classroom {
  final String code;
  final String title;
  final String teacherId;
  final List<String> students;

  Classroom({
    required this.code,
    required this.title,
    required this.teacherId,
    required this.students,
  });

  Map<String, dynamic> toMap() {
    return {
      "code": code,
      "title": title,
      "teacher": teacherId,
      "students": students,
    };
  }

  factory Classroom.fromMap(Map<String, dynamic> map) {
    return Classroom(
      code: map["code"] ?? "",
      title: map["title"] ?? "",
      teacherId: map["teacher"] ?? "",
      students: List<String>.from(map["students"] ?? []),
    );
  }
}