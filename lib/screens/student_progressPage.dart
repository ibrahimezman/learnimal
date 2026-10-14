import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../widgets/student_progress_bar.dart';
import 'student_dashboard.dart';
import '../screens/student_goalsPage.dart';
import 'admin_profilePage.dart';
import 'login_page.dart';

class StudentProgressPage extends StatefulWidget {
  const StudentProgressPage({
    super.key,
  });

  @override
  State<StudentProgressPage> createState() =>
      _StudentProgressPageState();
}

class _StudentProgressPageState extends State<StudentProgressPage> {
    bool isDaily = true; // show daily state & weekly state
    // daily statistics
    int dailyMinutes = 0; 
    int dailySessions = 0;

int weeklyMinutes = 0;
    final Map<String, int> weekData = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    // runs once when screen opens
    @override
    void initState() {
      super.initState();
      loadProgress(); // calls to fetch data
    }

  // load progress: fetches & calculates statistics from firestore
  // queries all studySessions doc + filter by data
  Future<void> loadProgress() async {
    final snapshot = await FirebaseFirestore.instance
    .collection("studySessions")
    .where("studentId", isEqualTo: LoginPage.loggedInStudentId,)
    .get();  // get all doc from collection
  
    DateTime now = DateTime.now();
    
    // calculate start of current week 
    // now.weekday returns 1=Monday, 7=Sunday
    // Subtract (weekday - 1) days to get back to Monday
    DateTime startOfWeek =
        now.subtract(
          Duration(
            days: now.weekday - 1,
          ),
        );

    // temp counters
    int todayMinutes = 0;
    int todaySessions = 0;
    int weekMinutes = 0;

    Map<String, int> tempWeekData = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    // loop thru all firestore doc
    for (var doc in snapshot.docs) {
      final data = doc.data();  // get doc fields as Map
      
      // extraact min studied in this session
      int focusTime = data["focusTime"] ?? 0;

      // parse the  timestamp string back to Datetime
      DateTime createdAt = DateTime.parse(data["createdAt"],); // store as timestamp, X string

      // daily
      // check if sessions was created today or not
      if (createdAt.year == now.year && createdAt.month == now.month && createdAt.day == now.day) {
        todayMinutes += focusTime;
        todaySessions++;
      }

      // weekly
      if (
        createdAt.isAfter(
          startOfWeek.subtract(const Duration(days: 1),),
        )
      ) {
        weekMinutes += focusTime; // add to weekly total

        String day = "";
        switch (createdAt.weekday) {
          case 1:
            day = "Mon";
            break;
          case 2:
            day = "Tue";
            break;
          case 3:
            day = "Wed";
            break;
          case 4:
            day = "Thu";
            break;
          case 5:
            day = "Fri";
            break;
          case 6:
            day = "Sat";
            break;
          case 7:
            day = "Sun";
            break;
        }
        // add focus time to the correct day's total in the map
        tempWeekData[day] = (tempWeekData[day] ?? 0) + focusTime;
      }
    }

    // update state - trigger UI rebuild w calculated statistics
    setState(() {
      dailyMinutes = todayMinutes;
      dailySessions = todaySessions;
      weeklyMinutes = weekMinutes;
      weekData.addAll(tempWeekData,); // merge temp data into state
    });
  }

  // constructs progress page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      
      // 4 buttons below
      bottomNavigationBar:
          BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor:AppColors.primaryBlue,
        unselectedItemColor:Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentDashboard(),
              ),
            );
          }

          else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentGoalsPage(),
              ),
            );
          }

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
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/goalsIcon.png',
              width: 24,
              height: 24,
            ),
            label: "Goals",
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/progressIcon.png',
              width: 24,
              height: 24,
            ),
            label: "Progress",
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/profileIcon.png',
              width: 24,
              height: 24,
            ),
            label: "Profile",
          ),
        ],
      ),

      // main body
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [
              // top header (logo + title)
              Row(
                children: [
                  Image.asset(
                    'assets/learnimalLogo.png',
                    width: 40,
                    height: 40,
                  ),
                  // title center w expanded
                  Expanded(
                    child: Center(
                      child: Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40,), // balance logo keep title centered
                ],
              ),

              const SizedBox(height: 25),

              // daily / weekly toggle buttons
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // daily btn
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isDaily = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDaily
                                ? AppColors.rewardYellow
                                : Colors.transparent,
                          ),
                          child: const Center(
                            child: Text("Daily"),
                          ),
                        ),
                      ),
                    ),

                    // weekly btn
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isDaily = false;  // switch to weekly view
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: !isDaily
                                ? AppColors.rewardYellow
                                : Colors.transparent,
                          ),
                          child: const Center(
                            child: Text("Weekly"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // daoly or weekly table
              Expanded(
                child: SingleChildScrollView( // allow scrolling for small phone
                  child: isDaily
                      ? Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.rewardYellow,
                                  width: 3,
                                ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Today's Summary",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 20,),

                              // total focus min
                              Text(
                                "$dailyMinutes min",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("Focus Time",),
                              const SizedBox(height: 25,),

                              // total completed session
                              Text(
                                "$dailySessions",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const Text("Completed Sessions",),
                            ],
                          ),
                        )

                      //weekly table summary
                      : Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.rewardYellow,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "This Week Summary",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15,),

                              // map each day in weekData to a progress bar
                              // ... (spread operator, expands the list into individual widgets)
                              ...weekData.entries.map(
                                (entry) {
                                  return StudentProgressBar(
                                    day: entry.key,         // ex: "Mon", "Tue"
                                    minutes: entry.value,   // ex: 30, 45, 0
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // below total time box
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:AppColors.rewardYellow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text("Total Focus Time",),
                    const SizedBox(height: 10,),

                    Text(
                      isDaily
                        ? "$dailyMinutes min"
                        : "$weeklyMinutes min",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color:AppColors.darkText,
                      ),
                    ),
                    Text(
                      isDaily
                        ? "Today"
                        : "This Week",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}