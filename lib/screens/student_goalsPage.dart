import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../repositories/goals_repository.dart'; // handles firestore database operations
import 'student_notificationsPage.dart';
import '../widgets/student_goal_card.dart';
import 'student_progressPage.dart';
import 'admin_profilePage.dart';
import 'login_page.dart';


class StudentGoalsPage  extends StatefulWidget {
  const StudentGoalsPage ({super.key});

  @override
  State<StudentGoalsPage > createState() => _StudentGoalsPageState();
}

// manage text inpyt controllers & repository instance
class _StudentGoalsPageState extends State<StudentGoalsPage > {
  //controllers
  final TextEditingController goalController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  // firebase respository - bridge between UI & firebase
  final GoalsRepository repository = GoalsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // home
          if (index == 0) {

            Navigator.pop(context);
          }

          // goals
          else if (index == 1) {
            return;
          }

          // progress
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentProgressPage(),
              ),
          );
          }

          // profile
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminProfilePage(
                  role: "Student",
                  email: LoginPage.loggedInEmail,
                ),
              ),
            );
          }
        },

        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/homeIcon.png',
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/goalsIcon.png',
              width: 24,
              height: 24,
            ),
            label: 'Goals',
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/progressIcon.png',
              width: 24,
              height: 24,
            ),
            label: 'Progress',
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/profileIcon.png',
              width: 24,
              height: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),

      // main body
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // top bar (logo + my goal title + notification)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/learnimalLogo.png',
                    width: 40,
                    height: 40,
                  ),
                  Text(
                    "My Goals",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),

                  // ntif bell
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentNotificationsPage(),
                        ),
                      );
                    },

                    child: Icon(
                      Icons.notifications_none,
                      size: 30,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // add new goal button
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Add New Goal"),
                        // 2 txt input fields
                        content: Column(
                          mainAxisSize: MainAxisSize.min, // warp content heigh
                          children: [
                            TextField(
                              controller: goalController,
                              decoration: InputDecoration(
                                hintText: "Enter Goal",
                              ),
                            ),
                            SizedBox(height: 15),

                            TextField(
                              controller: timeController,
                              decoration: InputDecoration(
                                hintText: "Enter Study Time",
                              ),
                            ),
                          ],
                        ),

                        // action button (cancel + add)
                        actions: [
                          // cancel button
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),

                          // add button - saves to firebase
                          ElevatedButton(
                            onPressed: () async {
                              // save to firebase
                              await repository.addGoal(
                                goal: goalController.text,
                                time: timeController.text,
                                isDone: false,
                              );
                              // clear previous input for next use
                              goalController.clear();
                              timeController.clear();
                              Navigator.pop(context);
                            },
                            child: Text("Add"),
                          ),
                        ],
                      );
                    },
                  );
                },
                
                // style for add new goal button
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Add New Goal",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // firebase goals list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // stream: real-time connection to firestore goal collection
                  stream: FirebaseFirestore.instance
                      .collection("goals")
                      //.where("studentId", isEqualTo: currentStudentId,) // READ FROM LOGIN
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  
                  // rebuild UI whenever firesore data chages
                  builder: (context, snapshot) {

                    // loading of data from firebase
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(), // spinning loader
                      );
                    }

                    // empty ( X goals exist in firestore)
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No goals added yet.",

                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    // extract list of goal data
                    final docs = snapshot.data!.docs;

                    // scrollable list of goals 
                    return ListView.builder(
                      itemCount: docs.length, // num of goals
                      itemBuilder: (context, index) {
                        final goal = docs[index];
                        final data =
                            goal.data() as Map<String, dynamic>; // convert firestore doc to dart map
                        bool isDone =
                            data["isDone"] ?? false;
                        // return their status
                        return StudentGoalCard(
                            goal: data["goal"] ?? "",
                            time: data["time"] ?? "",
                            isDone: isDone,
                            // onChanges called when user toggles checkbox
                            onChanged: (value) async {
                              // update goal status in Firestore thru respository
                              await repository.updateGoalStatus(
                                docId: goal.id,
                                isDone: value ?? false,
                              );
                            },

                            // onDelete called when user delete goal
                            onDelete: () async {
                              // delete goal in Firestore thru respository
                              await repository.deleteGoal(
                                goal.id,
                              );
                            },
                          );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}