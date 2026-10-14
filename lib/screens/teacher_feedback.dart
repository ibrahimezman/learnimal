import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mae_learnimal_teacher/repositories/classroom_repository.dart';
import 'package:mae_learnimal_teacher/screens/login_page.dart';
import 'package:mae_learnimal_teacher/widgets/teacher_sidebar.dart';
import '../constants/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _isSidebarExtended = true;
  final int _pageNumber = 2;
  final _classroomRepo = ClassroomRepository();

  final DocumentReference _loggedInTeacher =
      FirebaseFirestore.instance.collection('users').doc(LoginPage.loggedInTeacherId);

  List<Map<String, String>> _studentsList = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();

  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _loadClassroomStudents();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Feedback Sender'),
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: Icon(
                  _isSidebarExtended
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarExtended = !_isSidebarExtended;
                  });
                },
              ),
      ),
      drawer: isMobile ? Drawer(child: _teacherSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) _teacherSidebar(isDrawer: false),
          if (!isMobile) const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Card(
                    elevation: 0,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.lightGray),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send Feedback',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a student from your classroom and write an encouraging message.',
                              style: TextStyle(
                                color: AppColors.darkText.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStudentId,
                              items: _studentsList.map(
                                    (student) => DropdownMenuItem<String>(
                                      value: student['id'],
                                      child: Text("${student['id']} - ${student['name']}"),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedStudentId = value);
                              },
                              decoration: const InputDecoration(
                                labelText: 'Student',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null ? 'Please select a student' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _feedbackController,
                              maxLines: 6,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1000),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Feedback Message',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a feedback message';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  
                                  try {
                                    await FirebaseFirestore.instance.collection('feedback').add({
                                      'createdAt': FieldValue.serverTimestamp(),
                                      'feedbackMessage': _feedbackController.text.trim(),
                                      'studentId': _selectedStudentId,
                                      'teacherId': LoginPage.loggedInTeacherId,
                                    });

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Feedback sent successfully!')),
                                    );

                                    _feedbackController.clear();
                                    setState(() => _selectedStudentId = _studentsList.isNotEmpty ? _studentsList.first['id'] : null);
                                  }
                                  catch (e) {
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to send feedback. Please try again.')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Submit Feedback'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadClassroomStudents() async {
    final students = await _classroomRepo.loadClassroomStudents(LoginPage.loggedInTeacherId);

    if (!mounted) return;

    setState(() {
      _studentsList = students;
      _selectedStudentId = students.isNotEmpty ? students.first['id'] : null;
    });
  }

  Widget _teacherSidebar({required bool isDrawer}) {
    return TeacherSidebar(
      isDrawer: isDrawer,
      isSidebarExtended: _isSidebarExtended,
      selectedPage: _pageNumber,
      teacherId: _loggedInTeacher.id,
    );
  }
}