import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'admin_manageUsersPage.dart';
import 'admin_statisticsPage.dart';
import 'admin_manageSubjectsPage.dart';
import 'admin_profilePage.dart';

class AdminDashboard extends StatefulWidget {
  final String email;
  const AdminDashboard({super.key, required this.email});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminManageUsersPage(),
      const AdminStatisticsPage(),
      const AdminManageSubjectsPage(),
      AdminProfilePage(role: "Admin", email: widget.email),
    ];
  }

  // get title for current active page
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Manage Users";
      case 1:
        return "System Statistics";
      case 2:
        return "Manage Subjects";
      case 3:
        return "My Profile";
      default:
        return "Admin Portal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/learnimalLogo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.shield, color: AppColors.white),
            ),
            const SizedBox(width: 10),
            Text(
              _getAppBarTitle(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Subjects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
