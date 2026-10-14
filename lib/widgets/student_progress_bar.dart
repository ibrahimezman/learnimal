import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StudentProgressBar extends StatelessWidget {
  final String day;
  final int minutes;

  const StudentProgressBar({
    super.key,

    required this.day,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    double progress = minutes / 60;

    if (progress > 1) {
      progress = 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(day),
          ),

          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.rewardYellow,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: Text(
              "$minutes min",
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}