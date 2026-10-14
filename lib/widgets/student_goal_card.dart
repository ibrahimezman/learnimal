import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StudentGoalCard extends StatelessWidget {
  final String goal;
  final String time;
  final bool isDone;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onChanged;

  const StudentGoalCard({
    super.key,

    required this.goal,
    required this.time,
    required this.isDone,

    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          // checkbox
          Checkbox(

            value: isDone,
            activeColor:
                AppColors.successGreen,

            onChanged: onChanged,
          ),

          const SizedBox(width: 10),

          // goal details
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? Colors.grey
                        : AppColors.darkText,

                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey[700],
                    ),

                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // delete button
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color:
                  AppColors.alertPink,
            ),
          ),
        ],
      ),
    );
  }
}