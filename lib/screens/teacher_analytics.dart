import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:mae_learnimal_teacher/constants/app_colors.dart';
import 'package:mae_learnimal_teacher/screens/login_page.dart';
import 'package:mae_learnimal_teacher/widgets/teacher_classroom_dropdown.dart'; 
import 'package:mae_learnimal_teacher/widgets/teacher_sidebar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DocumentSnapshot? _selectedClassroom;
  List<String> _studentsList = []; 
  final List<String> _dayLabels = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  bool _isSidebarExtended = true;
  final int _pageNumber = 1;

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
                onPressed: () => setState(() => _isSidebarExtended = !_isSidebarExtended),
              ),
        title: const Text(
          'Class Analytics',
          style: TextStyle(color: AppColors.darkText),
        ),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  ClassroomDropdown(
                    selectedClassroom: _selectedClassroom,
                    onClassroomSelected: (doc, classroom) {
                      setState(() {
                        _selectedClassroom = doc;
                        _studentsList = classroom.students;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _analyticsBody(),
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
          'Analytics Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'View class performance and study patterns.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _analyticsBody() {
    if (_selectedClassroom == null || _studentsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Select a class to view analytics.'),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('studySessions')
          .where('isCompleted', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final sessions = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final dynamic studentIdField = data['studentId'];

          final String studentId = studentIdField is DocumentReference
              ? studentIdField.id
              : studentIdField.toString();

          return _studentsList.contains(studentId);
        }).toList();

        final totalSessions = sessions.length;
        double totalFocusMinutes = 0;
        final dayCounts = List<int>.filled(7, 0);
        final hourCounts = List<int>.filled(24, 0);

        for (final doc in sessions) {
          final data = doc.data() as Map<String, dynamic>;

          final int focusTime = (data['focusTime'] ?? 0) as int;
          totalFocusMinutes += focusTime;

          final dynamic createdAtField = data['createdAt'];
          DateTime? createdAt;

          if (createdAtField is Timestamp) {
            createdAt = createdAtField.toDate();
          } else if (createdAtField is String) {
            createdAt = DateTime.tryParse(createdAtField);
          }

          if (createdAt != null) {
            final weekdayIndex = createdAt.weekday % 7;
            dayCounts[weekdayIndex]++;
            hourCounts[createdAt.hour]++;
          }
        }

        final avgFocusMinutes = totalSessions == 0 ? 0.0 : totalFocusMinutes / totalSessions;
        final totalFocusHours = totalFocusMinutes / 60.0;
        final busiestDayIndex = _maxIndex(dayCounts);
        final busiestHourIndex = _maxIndex(hourCounts);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kpiGrid(
              avgFocusMinutes,
              totalFocusHours,
              totalSessions,
              busiestDayIndex,
              busiestHourIndex,
            ),
            const SizedBox(height: 24),
            _chartCard(
              title: 'Sessions by Day',
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= _dayLabels.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                _dayLabels[idx],
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: dayCounts[i].toDouble(),
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _chartCard(
              title: 'Sessions by Hour',
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 4,
                          getTitlesWidget: (value, meta) {
                            final v = value.toInt();
                            if (v % 4 != 0) return const SizedBox.shrink();
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '$v',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(24, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: hourCounts[i].toDouble(),
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.rewardYellow,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiGrid(
    double avgFocusMinutes,
    double totalFocusHours,
    int totalSessions,
    int busiestDayIndex,
    int busiestHourIndex,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        final cards = [
          _metricCard(
            'Average Focus Time',
            '${avgFocusMinutes.toStringAsFixed(1)} minutes',
            Icons.timer_rounded,
            AppColors.primaryBlue,
          ),
          _metricCard(
            'Total Focus',
            '${totalFocusHours.toStringAsFixed(1)} hours',
            Icons.hourglass_top_rounded,
            AppColors.successGreen,
          ),
          _metricCard(
            'Total Sessions',
            '$totalSessions',
            Icons.task_alt_rounded,
            AppColors.rewardYellow,
          ),
          _metricCard(
            'Most Active Day',
            _dayLabels[busiestDayIndex],
            Icons.calendar_today_rounded,
            AppColors.primaryBlue,
          ),
          _metricCard(
            'Most Active Hour',
            '$busiestHourIndex:00',
            Icons.access_time_rounded,
            AppColors.successGreen,
          ),
        ];

        if (isWide) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards,
          );
        }

        return Column(
          children: cards
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: c,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkText.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  int _maxIndex(List<int> values) {
    if (values.isEmpty) return 0;
    int maxIdx = 0;
    for (int i = 1; i < values.length; i++) {
      if (values[i] > values[maxIdx]) maxIdx = i;
    }
    return maxIdx;
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