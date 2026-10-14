import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import 'login_page.dart';

class AdminProfilePage extends StatefulWidget {
  final String email;
  final String role;

  const AdminProfilePage({super.key, required this.email, required this.role});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = true;
  String _userName = "User Name";
  String _userRole = "Student";
  String _userDocId = "";

  // student personal metrics
  int _completedSessions = 0;
  int _totalFocusMinutes = 0;
  double _avgSessionMinutes = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // fetch credentials & study statistics from firestore
  Future<void> _loadProfileData() async {
    try {
      // 1. fetch user profile details
      final userQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: widget.email.trim().toLowerCase())
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final doc = userQuery.docs.first;
        final data = doc.data();
        setState(() {
          _userDocId = doc.id;
          _userName = data["name"] ?? "User Name";
          _userRole = data["role"] ?? widget.role;
        });

        // 2. if student, load personal study stats
        if (_userRole.toLowerCase() == "student") {
          final sessionsQuery = await FirebaseFirestore.instance
              .collection("studySessions")
              .where("studentId", isEqualTo: _userDocId)
              .get();

          int completedCount = 0;
          int totalMinutes = 0;

          for (var doc in sessionsQuery.docs) {
            final sessionData = doc.data();
            final isCompleted = sessionData["isCompleted"] ?? false;
            final focusTime = sessionData["focusTime"] ?? 0;

            if (isCompleted) {
              completedCount++;
              totalMinutes += focusTime as int;
            }
          }

          setState(() {
            _completedSessions = completedCount;
            _totalFocusMinutes = totalMinutes;
            _avgSessionMinutes = completedCount > 0
                ? totalMinutes / completedCount
                : 0.0;
          });
        }
      } else {
        // fallback to default widget params
        setState(() {
          _userName = widget.email.split("@").first.toUpperCase();
          _userRole = widget.role;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // sign out trigger
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isStudent = _userRole.toLowerCase() == "student";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // profile banner card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // big companion/user icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 72,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _userName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isStudent
                                ? AppColors.successGreen.withOpacity(0.2)
                                : AppColors.alertPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _userRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isStudent
                                  ? AppColors.darkText
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // account information section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.email_outlined,
                          "Email Address",
                          widget.email,
                        ),
                        if (_userDocId.isNotEmpty) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.fingerprint,
                            "User ID",
                            _userDocId,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // student statistics section (visible only to students)
                  if (isStudent) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My Study Analytics",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // study statistics grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatMiniCard(
                                  "Focus Hours",
                                  "${(_totalFocusMinutes / 60.0).toStringAsFixed(1)}h",
                                  Icons.hourglass_empty,
                                  AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatMiniCard(
                                  "Completed Sessions",
                                  "$_completedSessions",
                                  Icons.check_circle_outline,
                                  AppColors.successGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatMiniCard(
                                  "Avg. Duration",
                                  "${_avgSessionMinutes.toStringAsFixed(0)}m",
                                  Icons.query_stats,
                                  AppColors.rewardYellow,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatMiniCard(
                                  "Total Minutes",
                                  "${_totalFocusMinutes}m",
                                  Icons.timer_outlined,
                                  AppColors.alertPink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // logout button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertPink,
                        foregroundColor: AppColors.darkText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // individual info row widget
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // analytics item widget
  Widget _buildStatMiniCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color == AppColors.rewardYellow ? AppColors.darkText : color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
