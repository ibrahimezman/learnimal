import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'student_pomodoroPage.dart';
import 'student_goalsPage.dart';
import 'student_notificationsPage.dart';
import 'student_progressPage.dart';
import 'admin_profilePage.dart';
import 'login_page.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // default selected / most common option
  int selectedTime = 30;
  int selectedSession = 2;
  
  // default animal 
  String selectedAnimal =
    "assets/catImage.gif";

  // all available animals
  List<String> animalList = [
  "assets/catImage.gif",
  "assets/dogImage.gif",
  "assets/dog2Image.gif",
  "assets/dog3Image.gif",
  "assets/bearImage.gif",
  "assets/rabbitImage.gif",
  "assets/snoopyImage.gif",
  ];

  // build method for ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // make sure the labels show everytime
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
        // home
        if (index == 0) {
          return;
        }
        
        // goals
        else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentGoalsPage(),
            ),
          );
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

        // bottom nav bar
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

      //main body content
      body: SafeArea(
        child: SingleChildScrollView(  // smaller phone can scroll
          child: Padding(
            padding: const EdgeInsets.all(20), // margin on all sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left align content
              children: [
                // top header logo + learnimal name + notif
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/learnimalLogo.png', // logo
                      width: 40,
                      height: 40,
                    ),

                    Text(
                      "Learnimal",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    //notification button
                    GestureDetector(
                      onTap: () {
                        // navigate to notification page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentNotificationsPage(),
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

                const SizedBox(height: 25), // spacer

                Row(
                  children: [
                    // left welcome message card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20), // rounded side
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, Student!",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Click to change companion ->",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // right animal display
                    Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector( // let user click to change companion
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Choose Your Companion",
                                  ),
                                  // wrap w box 
                                  content: SizedBox(
                                    width: 300,
                                    child: Wrap(
                                      spacing: 10,      // horizontal gap
                                      runSpacing: 10,   // vertical gap
                                      children: animalList.map((animal) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedAnimal = animal;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Image.asset(
                                            animal,
                                            width: 60,
                                            height: 60,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          // show selected animal 
                          child: Image.asset(
                            selectedAnimal,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // lets start study title + time + num of sessions
                Text(
                  "Let's Start Study! :D",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 20),

                // pickfocus time middle part
                progressCard(
                  title: "Pick Focus Time:",
                  icon: Icons.access_time,
                  children: [
                    timeButton(15),
                    timeButton(30),
                    timeButton(45),
                  ],
                ),

                const SizedBox(height: 20),

                // pick num of session
                progressCard(
                  title: "Pick Number of Sessions:",
                  icon: Icons.track_changes,
                  children: [
                    sessionButton(1),
                    sessionButton(2),
                    sessionButton(3),
                  ],
                ),

                // capoo image
                const SizedBox(height: 25),
                  Center(
                    child: Image.asset(
                        "assets/capooImage.gif",
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                  ),
                  
                const SizedBox(height: 20),  // so X overflow

                // start study button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // navigate to pomdoro page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentPomodoroPage(
                            focusTime: selectedTime,
                            sessionCount: selectedSession,
                            animalImage: selectedAnimal,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Start Study Session",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // can be reuse for time and num of session
  Widget progressCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row: icon + title
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.darkText,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // row of buttons (time or num of sessions options)
          Row(children: children,),
        ],
      ),
    );
  }

  // can be reuse for time button selection
  Widget timeButton(int time) {
    // checl if button's time match current selected time
    bool isSelected = selectedTime == time;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // update state when user click so UI rebuild
          setState(() {
            selectedTime = time;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10), // gap between buttons
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.lightGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$time min", // display 15, 30 or 45 mins
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.white
                    : AppColors.darkText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // can reuse for session button select
  Widget sessionButton(int session) {
    // check selected button
    bool isSelected = selectedSession == session;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSession = session;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.lightGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$session", // display 1, 2 or 3
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.white
                    : AppColors.darkText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}