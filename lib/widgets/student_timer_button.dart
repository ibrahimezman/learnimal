import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StudentTimerButton extends StatelessWidget {

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const StudentTimerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),

        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(16),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: AppColors.darkText,
            ),

            const SizedBox(height: 8),

            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}