import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/classrooms.dart';
import '../screens/login_page.dart';

class ClassroomDropdown extends StatelessWidget {
  final dynamic selectedClassroom;
  final Function(QueryDocumentSnapshot doc, Classroom classroom) onClassroomSelected;

  const ClassroomDropdown({
    super.key,
    required this.selectedClassroom,
    required this.onClassroomSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classrooms')
          .where('teacher', isEqualTo: LoginPage.loggedInTeacherId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
            height: 56,
            child: Center(child: Text('No classrooms found.')),
          );
        }

        final docs = snapshot.data!.docs;
        final classrooms = docs
            .map((doc) => Classroom.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        if (selectedClassroom == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onClassroomSelected(docs.first, classrooms.first);
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedClassroom?.id,
              hint: const Text('Select Classroom'),
              items: List.generate(docs.length, (idx) {
                final classroom = classrooms[idx];
                return DropdownMenuItem<String>(
                  value: docs[idx].id,
                  child: Text('${classroom.title} (${classroom.code})'),
                );
              }),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                final idx = docs.indexWhere((doc) => doc.id == newValue);
                if (idx == -1) return;
                onClassroomSelected(docs[idx], classrooms[idx]);
              },
            ),
          ),
        );
      },
    );
  }
}