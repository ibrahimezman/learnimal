import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class TeacherPomodoroPanel extends StatelessWidget {
  final bool isActive;
  final TextEditingController hourController;
  final TextEditingController minController;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const TeacherPomodoroPanel({
    super.key,
    required this.isActive,
    required this.hourController,
    required this.minController,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Classroom Pomodoro Session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 16),
          Card(
            color: isActive
                ? AppColors.alertPink.withValues(alpha: 0.15)
                : AppColors.background,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? AppColors.alertPink : AppColors.lightGray,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: isActive
                            ? AppColors.alertPink
                            : AppColors.darkText.withValues(alpha: 0.6),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Classroom Pomodoro Session',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isActive
                                  ? 'Session running for all students...'
                                  : 'Start a pomodoro session for all students in this class.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hourController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Hours',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Minutes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isActive ? onStop : onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? AppColors.alertPink
                            : AppColors.primaryBlue,
                        foregroundColor: isActive
                            ? AppColors.darkText
                            : AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: Text(isActive ? 'Cancel Session' : '1-Click Start'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}