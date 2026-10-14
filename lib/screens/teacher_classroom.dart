import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mae_learnimal_teacher/constants/app_colors.dart';
import 'package:mae_learnimal_teacher/models/classrooms.dart';
import 'package:mae_learnimal_teacher/repositories/reward_repository.dart';
import 'package:mae_learnimal_teacher/screens/login_page.dart';
import 'package:mae_learnimal_teacher/widgets/teacher_classroom_dropdown.dart';
import 'package:mae_learnimal_teacher/widgets/teacher_sidebar.dart';
import 'package:mae_learnimal_teacher/screens/teacher_studentview.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  DocumentSnapshot? _selectedClassroom;
  List<DocumentSnapshot<Map<String, dynamic>>> _studentDocs = [];

  bool _isSidebarExtended = true;
  final int _pageNumber = 3;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? _teacherSidebar(isDrawer: true) : null,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.darkText),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: Icon(
                  _isSidebarExtended
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                  color: AppColors.darkText,
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarExtended = !_isSidebarExtended;
                  });
                },
              ),
        title: const Text(
          'Classroom Management',
          style: TextStyle(color: AppColors.darkText),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.lightGray),
        ),
      ),
      body: Row(
        children: [
          if (!isMobile) _teacherSidebar(isDrawer: false),
          if (!isMobile)
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.lightGray,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  ClassroomDropdown(
                    selectedClassroom: _selectedClassroom,
                    onClassroomSelected: (doc, classroom) {
                      _loadStudentsForClassroom(doc, classroom);
                    },
                  ),
                  const SizedBox(height: 20),
                  _giftButtonPanel(),
                  const SizedBox(height: 20),
                  _studentsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enrolled Students',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Select a classroom to view students and open profiles.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _giftButtonPanel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: _studentDocs.isEmpty ? null : _showGiftRewardDialog,
        icon: const Icon(Icons.card_giftcard_rounded),
        label: const Text('Gift Additional Coins'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _loadStudentsForClassroom(
    DocumentSnapshot selectedDoc,
    Classroom classroom,
  ) async {
    final refs = classroom.students
        .map((id) => FirebaseFirestore.instance.collection('users').doc(id))
        .toList();

    final docs = <DocumentSnapshot<Map<String, dynamic>>>[];
    for (final ref in refs) {
      final snap = await ref.get();
      if (snap.exists) {
        docs.add(snap);
      }
    }

    if (!mounted) return;
    setState(() {
      _selectedClassroom = selectedDoc;
      _studentDocs = docs;
    });
  }

  Future<void> _showGiftRewardDialog() async {
    String? selectedStudentId = _studentDocs.isNotEmpty ? _studentDocs.first.id : null;
    final rewardController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Gift Additional Coins'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedStudentId,
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                      ),
                      items: _studentDocs.map((doc) {
                        final data = doc.data() ?? <String, dynamic>{};
                        final name = (data['fullName'] ?? data['name'] ?? 'Student').toString();
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStudentId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rewardController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reward Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () async {
                    final studentId = selectedStudentId;
                    final points = int.tryParse(rewardController.text.trim()) ?? 0;
                    final note = noteController.text.trim();

                    if (studentId == null || points <= 0) return;

                    final isSuccess = await RewardRepository().giftReward(
                      studentId: studentId,
                      teacherId: LoginPage.loggedInTeacherId,
                      amount: points,
                      note: note,
                    );
                    
                    Navigator.of(dialogContext).pop();
                    
                    Future.delayed(Duration.zero, () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSuccess 
                                  ? 'Reward gifted successfully.' 
                                  : 'Failed to gift reward. Please try again.'
                            ),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text('Gift'),
                ),
              ],
            );
          },
        );
      },
    );

    rewardController.dispose();
    noteController.dispose();
  }

  Widget _studentsSection() {
    if (_selectedClassroom == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Select a class to view students.'),
        ),
      );
    }

    if (_studentDocs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No enrolled students found.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Students (${_studentDocs.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _studentDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final student = _studentDocs[index].data() ?? {};
            final studentId = _studentDocs[index].id;
            final name = (student['fullName'] ?? student['name'] ?? 'Student').toString();
            final email = (student['email'] ?? '').toString();

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TeacherStudentViewScreen(
                      studentId: studentId,
                      studentData: student,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.darkText.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.darkText),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _teacherSidebar({required bool isDrawer}) {
    return TeacherSidebar(
      isDrawer: isDrawer,
      isSidebarExtended: _isSidebarExtended,
      selectedPage: _pageNumber,
      teacherId: LoginPage.loggedInTeacherId,
    );
  }
}