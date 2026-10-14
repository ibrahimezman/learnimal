import 'package:flutter/material.dart';
import 'package:mae_learnimal_teacher/constants/app_colors.dart';
import 'package:mae_learnimal_teacher/models/study_sessions.dart';
import 'package:mae_learnimal_teacher/repositories/study_repository.dart';

class TeacherStudentViewScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const TeacherStudentViewScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  State<TeacherStudentViewScreen> createState() => _TeacherStudentViewScreenState();
}

class _TeacherStudentViewScreenState extends State<TeacherStudentViewScreen> {
  final StudyRepository _studyRepo = StudyRepository();
  final ScrollController _historyController = ScrollController();

  @override
  void dispose() {
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.studentData['fullName'] ?? widget.studentData['name'] ?? 'Unnamed Student').toString();
    final email = (widget.studentData['email'] ?? 'No email').toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<List<StudySession>>(
        future: _studyRepo.getStudentHistory(widget.studentId),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? [];
          final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.focusTime);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightGray),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),

                  const SizedBox(height: 12),
                  _profileRow('Student ID', widget.studentId),
                  _profileRow('Email', email),
                  _profileRow('Total Focus Time', _formatMinutes(totalMinutes)),
                  const SizedBox(height: 24),

                  const Text(
                    'Study Session History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator()) : sessions.isEmpty
                      ? const Center(child: Text('No study sessions found.')) : Scrollbar(
                        controller: _historyController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        
                        child: ListView.separated(
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return _sessionTile(session);
                          },
                        ),
                      ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sessionTile(StudySession session) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatMinutes(session.focusTime),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(session.createdAt),
            style: TextStyle(
              color: AppColors.darkText.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.isCompleted ? 'Completed' : 'In progress',
            style: TextStyle(
              color: session.isCompleted ? Colors.green : AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return '$hours hours $mins minutes';
    if (hours > 0) return '$hours hours';
    return '$mins minutes';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.darkText.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}