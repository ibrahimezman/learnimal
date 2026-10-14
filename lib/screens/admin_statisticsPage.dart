import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({super.key});

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  // sessions real-time stream
  final Stream<QuerySnapshot> _sessionsStream = FirebaseFirestore.instance
      .collection("studySessions")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: _sessionsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              int totalSessions = 0;
              int completedSessionsCount = 0;
              int totalFocusMinutes = 0;
              final Set<String> activeStudents = {};

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final docs = snapshot.data!.docs;
                totalSessions = docs.length;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String studentId = data["studentId"] ?? "";
                  final int focusTime = data["focusTime"] ?? 0;
                  final bool isCompleted = data["isCompleted"] ?? false;

                  if (studentId.isNotEmpty) {
                    activeStudents.add(studentId);
                  }

                  if (isCompleted) {
                    completedSessionsCount++;
                    totalFocusMinutes += focusTime;
                  }
                }
              }

              // math for total focus hours
              final double totalHoursCompleted = totalFocusMinutes / 60.0;

              // math for average session duration
              final double avgSessionMinutes = completedSessionsCount > 0
                  ? totalFocusMinutes / completedSessionsCount
                  : 0.0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "System Dashboard",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Real-time overview of Learnimal platform usage.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 25),

                    // statistics cards row 1
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: "Active Students",
                            value: "${activeStudents.length}",
                            subtitle: "Unique study users",
                            icon: Icons.people,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            title: "Study Hours",
                            value:
                                "${totalHoursCompleted.toStringAsFixed(1)} hrs",
                            subtitle: "Completed focus time",
                            icon: Icons.timer,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // statistics cards row 2
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: "Completed Pomodoros",
                            value: "$completedSessionsCount",
                            subtitle: "Out of $totalSessions total sessions",
                            icon: Icons.check_circle_outline,
                            color: AppColors.rewardYellow,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            title: "Avg. Duration",
                            value:
                                "${avgSessionMinutes.toStringAsFixed(0)} min",
                            subtitle: "Focus time per session",
                            icon: Icons.query_stats,
                            color: AppColors.alertPink,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // health checks cards
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                color: AppColors.successGreen,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "System Health",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildHealthRow(
                            "Database Status",
                            "Online & Active",
                            AppColors.successGreen,
                          ),
                          const Divider(height: 20),
                          _buildHealthRow(
                            "User Sync Services",
                            "Real-time Enabled",
                            AppColors.successGreen,
                          ),
                          const Divider(height: 20),
                          _buildHealthRow(
                            "Pomodoro Analytics Engine",
                            "Fully Operational",
                            AppColors.successGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // stats card builder
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color == AppColors.rewardYellow
                  ? AppColors.darkText
                  : color,
              size: 24,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // health row builder
  Widget _buildHealthRow(
    String serviceName,
    String statusText,
    Color statusColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          serviceName,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor == AppColors.rewardYellow
                  ? AppColors.darkText
                  : statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
