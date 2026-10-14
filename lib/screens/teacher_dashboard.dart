import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_learnimal_teacher/models/classrooms.dart';
import 'package:mae_learnimal_teacher/models/study_sessions.dart';
import 'package:mae_learnimal_teacher/repositories/classroom_repository.dart';
import 'package:mae_learnimal_teacher/repositories/study_repository.dart';
import 'package:mae_learnimal_teacher/screens/login_page.dart';
import 'package:mae_learnimal_teacher/widgets/teacher_pomodoro_panel.dart';
import 'package:mae_learnimal_teacher/widgets/teacher_sidebar.dart';
import '../repositories/teacher_repository.dart';
import '../repositories/student_repository.dart';
import '../constants/app_colors.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/login': (context) => const Scaffold(body: Center(child: Text('Login Screen Placeholder'))),
      '/analytics': (context) => const Scaffold(body: Center(child: Text('Student Analytics'))),
      '/feedback': (context) => const Scaffold(body: Center(child: Text('Feedback Hub'))),
      '/classroom_management': (context) => const Scaffold(body: Center(child: Text('Classroom Management'))),
    };
  }

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool _isSidebarExtended = true;
  final int _pageNumber = 0;
  bool _isActive = false;

  DocumentSnapshot? _selectedClassroom;
  List<DocumentReference> _studentsList = [];

  String _teacherName = 'Teacher';

  final TextEditingController _hourController = TextEditingController(text: '0');
  final TextEditingController _minController = TextEditingController(text: '0');

  final TeacherRepository _teacherRepo = TeacherRepository();
  final ClassroomRepository _classroomRepo = ClassroomRepository();
  final StudentRepository _studentRepo = StudentRepository();
  
  Timer? _pomodoroTimer;
  String? _activeSessionId;
  bool _sessionCancelled = false; // check if session was stopped abruptly

  @override
  void initState() {
    super.initState();
    _loadTeacherName();
  }

  // fetch the teacher's profile details from firestore
  Future<void> _loadTeacherName() async {
    final name = await _teacherRepo.getTeacherName(LoginPage.loggedInTeacherId);
    
    if (mounted) {
      setState(() {
        _teacherName = name;
      });
    }
  }

  Future<void> _startSession() async {
    if (_selectedClassroom == null || _studentsList.isEmpty) return;
    
    final int focusMinutes = _calculateMinutes();
    if (focusMinutes <= 0) return;

    final sessionId = await _teacherRepo.startSession(
      teacherId: LoginPage.loggedInTeacherId,
      selectedClassroom: _selectedClassroom!,
      studentsList: _studentsList,
      focusMinutes: focusMinutes,
    );

    if (sessionId == null || !mounted) return;

    setState(() {
      _isActive = true;
      _activeSessionId = sessionId;
      _sessionCancelled = false;
    });

    _pomodoroTimer?.cancel();
    _pomodoroTimer = Timer(Duration(minutes: focusMinutes), () {
      if (!mounted) return;
      setState(() => _sessionCancelled = true);
      _stopSession();
    });
  }

  Future<void> _stopSession() async {
    await _teacherRepo.stopSession(
      activeSessionId: _activeSessionId,
      sessionCancelled: _sessionCancelled,
      focusMinutes: _calculateMinutes(),
      studentsList: _studentsList,
    );

    _pomodoroTimer?.cancel();
    
    if (mounted) {
      setState(() {
        _isActive = false;
        _activeSessionId = null;
      });
    }
  }

  int _calculateMinutes() {
    final hours = int.tryParse(_hourController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minController.text.trim()) ?? 0;
    return (hours * 60) + minutes;
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Confirm log out?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? _teacherSidebar(isDrawer: true) : null,
      
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(color: AppColors.darkText),
        ),
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
                onPressed: () => setState(() => _isSidebarExtended = !_isSidebarExtended),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.darkText),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0, color: AppColors.lightGray),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  
                  const SizedBox(height: 24),
                  _analyticsSummary(),
                  
                  const SizedBox(height: 24),
                  _mainWorkspace(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // top section containing the welcome text and classroom dropdown selection
  Widget _header() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;

        final headingText = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_teacherName!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text(
              'Real-time metrics and gamification controls.',
              style: TextStyle(
                color: AppColors.darkText.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        );

        final classroomSelector = StreamBuilder<QuerySnapshot>(
          stream: _classroomRepo.classrooms
              .where('teacher', isEqualTo: LoginPage.loggedInTeacherId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError || snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const SizedBox(
                width: 200,
                child: Text(
                  'Loading classrooms...',
                  style: TextStyle(color: AppColors.darkText),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final classrooms = docs
                .map((doc) => Classroom.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            if (_selectedClassroom == null && classrooms.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedClassroom = docs.first;
                  _studentsList = _studentRepo.getStudentsList(classrooms.first.students);
                });
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
                  value: _selectedClassroom?.id,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  hint: const Text('Select Classroom'),
                  dropdownColor: AppColors.white,
                  items: classrooms.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final classroom = entry.value;
                    return DropdownMenuItem<String>(
                      value: docs[idx].id,
                      child: Text(
                        '${classroom.title} (${classroom.code})',
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue == null) return;

                    final targetIdx = docs.indexWhere((doc) => doc.id == newValue);
                    if (targetIdx != -1) {
                      setState(() {
                        _selectedClassroom = docs[targetIdx];
                        _studentsList = _studentRepo.getStudentsList(classrooms[targetIdx].students);
                      });
                    }
                  },
                ),
              ),
            );
          },
        );

        return isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [headingText, classroomSelector],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headingText,
                  const SizedBox(height: 16),
                  classroomSelector,
                ],
              );
      },
    );
  }

  Widget _analyticsSummary() {
    if (_studentsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No data available for the selected class.'),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _studentRepo.getAllStudents(),
      builder: (context, userSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _teacherRepo.getActiveSessions(),
          builder: (context, sessionSnapshot) {
            double totalHours = 0.0;
            int activeStudents = 0;

            final Set<String> studentIds = _studentsList.map((ref) => ref.id).toSet();

            // calculate total focus hours from all students in the class
            if (userSnapshot.hasData) {
              for (final doc in userSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final studentId = doc.id;

                if (studentIds.contains(studentId)) {
                  final int focusMinutes = data['totalFocusTime'] ?? 0;
                  totalHours += (focusMinutes / 60.0);
                }
              }
            }

            // calculate number of active students
            if (sessionSnapshot.hasData) {
              for (final doc in sessionSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final studentId = data['studentId'];

                if (studentId != null && studentIds.contains(studentId)) {
                  activeStudents++;
                }
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final bool useHorizontalRow = constraints.maxWidth > 700;

                final cards = [
                  _cardSlot(
                    useHorizontalRow,
                    _card(
                      'Total Focus Hours',
                      '${totalHours.toStringAsFixed(1)} hours',
                      Icons.hourglass_top_rounded,
                      AppColors.primaryBlue,
                      'Class total hours',
                    ),
                  ),
                  _cardSlot(
                    useHorizontalRow,
                    _card(
                      'Currently Studying',
                      '$activeStudents active',
                      Icons.bolt_rounded,
                      AppColors.successGreen,
                      'Live in classroom',
                    ),
                  ),
                ];

                return useHorizontalRow
                    ? Row(children: cards)
                    : Column(children: cards);
              },
            );
          },
        );
      },
    );
  }

  Widget _cardSlot(bool isRow, Widget child) {
    return isRow
        ? Expanded(child: child)
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          );
  }

  Widget _card(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      height: 140.0,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.darkText.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.darkText.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mainWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 900;

        return isWideScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _teacherPomodoroPanel()),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: SizedBox(height: 400, child: _liveActivityFeed(isWide: true)), 
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _teacherPomodoroPanel(),
                  const SizedBox(height: 24),
                  _liveActivityFeed(isWide: false), 
                ],
              );
      },
    );
  }

  Widget _teacherPomodoroPanel() {
    return TeacherPomodoroPanel(
      isActive: _isActive,
      hourController: _hourController,
      minController: _minController,
      onStart: _startSession,
      onStop: _stopSession,
      );
  }

  Widget _liveActivityFeed({required bool isWide}) {
    Widget buildContent() {
      return _studentsList.isEmpty
          ? const Center(child: Text('No students registered in this class.'))
          : StreamBuilder<QuerySnapshot>(
              stream: StudyRepository()
                  .studyCollection
                  .where('isCompleted', isEqualTo: false)
                  .snapshots(),
              builder: (context, sessionSnapshot) {
                if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final Map<String, StudySession> activeSessionsMap = {};

                if (sessionSnapshot.hasData && sessionSnapshot.data?.docs != null) {
                  for (final doc in sessionSnapshot.data!.docs) {
                    final rawData = doc.data() as Map<String, dynamic>?;
                    if (rawData == null) continue;

                    final Map<String, dynamic> modifiedData = Map.from(rawData);
                    if (modifiedData['createdAt'] is Timestamp) {
                      modifiedData['createdAt'] =
                          (modifiedData['createdAt'] as Timestamp).toDate().toIso8601String();
                    }

                    final StudySession session = StudySession.fromMap(modifiedData);
                    if (session.studentId.isNotEmpty) {
                      activeSessionsMap[session.studentId] = session;
                    }
                  }
                }

                return ListView.builder(
                  itemCount: _studentsList.length,
                  shrinkWrap: !isWide, 
                  physics: isWide 
                      ? const AlwaysScrollableScrollPhysics() 
                      : const NeverScrollableScrollPhysics(), 
                  itemBuilder: (context, index) {
                    final DocumentReference student = _studentsList[index];
                    final String studentId = student.id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: student.get(),
                      builder: (context, studentSnapshot) {
                        if (!studentSnapshot.hasData) {
                          return const SizedBox(height: 56);
                        }

                        final userData = studentSnapshot.data?.data() as Map<String, dynamic>?;
                        if (userData == null) return const SizedBox.shrink();

                        final String studentName = userData['name'] ?? 'Unknown Student';
                        final bool isCurrentlyLive = activeSessionsMap.containsKey(studentId);

                        String dynamicSubtitle = 'Offline';
                        if (isCurrentlyLive) {
                          final StudySession currentSession = activeSessionsMap[studentId]!;
                          dynamicSubtitle =
                              'Active Session • ${currentSession.sessionCount} (${currentSession.focusTime} mins)';
                        }

                        return _activeStudents(studentName, dynamicSubtitle, isCurrentlyLive);
                      },
                    );
                  },
                );
              },
            );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Classroom Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          isWide 
              ? Expanded(child: buildContent()) 
              : buildContent(),
        ],
      ),
    );
  }

  Widget _activeStudents(String name, String status, bool isActive, {String? customSub}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isActive
            ? AppColors.successGreen.withValues(alpha: 0.15)
            : AppColors.primaryBlue.withValues(alpha: 0.1),
        child: Text(
          name.isNotEmpty ? name[0] : 'S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.successGreen : AppColors.primaryBlue,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.darkText,
        ),
      ),
      subtitle: Text(
        customSub ?? status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: isActive
              ? AppColors.successGreen.withValues(alpha: 0.9)
              : AppColors.darkText.withValues(alpha: 0.6),
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: isActive
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
            )
          : const SizedBox(width: 10)
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