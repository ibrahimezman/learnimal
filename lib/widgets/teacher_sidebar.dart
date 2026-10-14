import 'package:flutter/material.dart';
import 'package:mae_learnimal_teacher/screens/teacher_dashboard.dart';
import '../constants/app_colors.dart';
import '../screens/teacher_analytics.dart';
import '../screens/teacher_classroom.dart';
import '../screens/teacher_feedback.dart';

class TeacherSidebar extends StatelessWidget {
  final bool isDrawer;
  final bool isSidebarExtended;
  final int selectedPage;
  final String teacherId;

  const TeacherSidebar({
    super.key,
    required this.isDrawer,
    required this.isSidebarExtended,
    required this.selectedPage,
    required this.teacherId,
  });

  void _navigate(BuildContext context, int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = TeacherDashboard();
        break;
      case 1:
        screen = const AnalyticsScreen();
        break;
      case 2:
        screen = const FeedbackScreen();
        break;
      case 3:
        screen = const ClassroomScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Image.asset(
                  'assets/learnimalLogo.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),

                const Text(
                  'Learnimal',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 2),

          Expanded(
            child: ListView.builder(
              itemCount: 4,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              
              itemBuilder: (context, index) {
                final icons = [
                  Icons.home_rounded,
                  Icons.bar_chart_rounded,
                  Icons.rate_review_rounded,
                  Icons.groups_rounded,
                  Icons.account_circle
                ];

                final labels = [
                  'Dashboard',
                  'Analytics',
                  'Feedback',
                  'Classroom'
                ];

                final isSelected = index == selectedPage;

                return ListTile(
                  leading: Icon(
                    icons[index],
                    color: isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.7),
                  ),
                  title: Text(
                    labels[index],
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  
                  selected: isSelected,
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigate(context, index);
                  },
                );
              },
            ),
          )
        ]
      ),
    );
  }
}