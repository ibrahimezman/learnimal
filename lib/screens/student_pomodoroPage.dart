import 'package:flutter/material.dart';
import 'dart:async';  // provide timer class for countdown
import 'dart:convert';  // for api response parsing
import 'package:http/http.dart' as http;  // for calling zenquotes api
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/app_colors.dart';
import '../models/study_sessions.dart';
import '../repositories/study_repository.dart'; // for saving study session to firebase
import '../repositories/student_notifications_repository.dart'; // for creating notif when session completes
import '../widgets/student_timer_button.dart';
import '../screens/login_page.dart';

// From dashboard:
// - focusTime: duration in minutes (e.g., 30)
// - sessionCount: number of Pomodoro rounds (e.g., 2)
// - animalImage: selected virtual pet image path
class StudentPomodoroPage extends StatefulWidget {
  final int focusTime;
  final int sessionCount;
  final String animalImage;

  const StudentPomodoroPage({
    super.key,
    required this.focusTime,
    required this.sessionCount,
    required this.animalImage,
  });

  @override
  State<StudentPomodoroPage> createState() => _StudentPomodoroPageState();
}

// manages timer logic, quote fetching & session tracking
class _StudentPomodoroPageState extends State<StudentPomodoroPage> {
  Timer? timer; // reference to the periodic timer that ticks every sec & the ? is like detect null bc timer X yet start

  late int totalSeconds;
  late int remainingSeconds;
  int currentSession = 1;
  bool isRunning = false;

  final StudyRepository repository = StudyRepository(); // save completed sessions to firestore
  final StudentNotificationsRepository notificationsRepository = StudentNotificationsRepository();  // generate notif after session ended

  // zenquote api
  String quote = "Loading the motivation quote...";
  String author = "";

  @override
  void initState() {
    super.initState();

    //FOR TESTING USE: 
    //totalSeconds = 10;  
    totalSeconds = widget.focusTime * 60;
    remainingSeconds = totalSeconds;

    fetchQuote();
  }

  // fetch randome quote
  Future<void> fetchQuote() async {

  // load quote
  setState(() {
    quote = "Loading motivation quote...";
    author = "";
  });

  // backup quotes
  List<Map<String, String>> localQuotes = [
    {
      "q": "If you are not willing to learn, no one can help you. If you are determined to learn, no one can stop you.",
      "a": "Zig Ziglar"
    },

    {
      "q": "Don't let what you cannot do interfere with what you can do.",
      "a": "John Wooden"
    },

    {
      "q": "Success is the sum of small efforts, repeated day in and day out.",
      "a": "Robert Collier"
    },

    {
      "q": "Success isn't overnight. It's when every day you get a little better than the day before. It all adds up.",
      "a": "Dwayne Johnson"
    },

    {
      "q": "Success doesn't come to you, you go to it.",
      "a": "Marva Collins"
    },
  ];

  try {
    // call api to get randopm quote
    final response = await http.get(
      Uri.parse("https://zenquotes.io/api/random"),
    );

    // if zenquotes success, then use zenquotes
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        quote = data[0]["q"] ?? localQuotes[0]["q"]!;
        author = data[0]["a"] ?? localQuotes[0]["a"]!;
      });
    } else {
      // use back backuo quotes if fail to loadd (return error 404/500)
      localQuotes.shuffle();
      setState(() {
        quote = localQuotes.first["q"]!;
        author = localQuotes.first["a"]!;
      });
    }
  } catch (e) {
    // use backup quotes if zenquotes fail
    localQuotes.shuffle();
    setState(() {
      quote = localQuotes.first["q"]!;
      author = localQuotes.first["a"]!;
    });
  }
}

  Future<void> saveCompletedSession() async {
    try {
      StudySession session = StudySession(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: LoginPage.loggedInStudentId,
        focusTime: widget.focusTime, // 15, 30, 45 mins
        sessionCount: 1, // always 1
        createdAt: DateTime.now(),
        isCompleted: true,
      );

      // save session to firestore thru respository
      await repository.saveStudySession(session);

      // create notif in firebase
      await notificationsRepository.addNotification(
        title: "Session Completed",
        message:
            "Congratulations! You have completed a study session. :D",
      );

      // success message for 1 session
      // if (mounted) {
      //   showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(20),
      //         ),

      //         title: Text(
      //           "Session Completed WOOHOO!",
      //           style: TextStyle(
      //             fontWeight: FontWeight.bold,
      //             color: AppColors.darkText,
      //           ),
      //         ),

      //         content: Text(
      //           "Great job! Your study session has been saved to progress.",

      //           style: TextStyle(
      //             color: AppColors.darkText,
      //             height: 1.5,
      //           ),
      //         ),

      //         actions: [
      //           ElevatedButton(
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: AppColors.primaryBlue,
      //             ),

      //             onPressed: () {
      //               Navigator.pop(context);
      //               Navigator.pop(context);
      //             },

      //             child: Text(
      //               "Continue",

      //               style: TextStyle(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // }

    } catch (e) {
      print("Error saving completed session: $e");
    }
  }
  
  // start timer
  void startTimer() {
    // prevent starting if running dy (avoid multiple timers)
    if (isRunning) return;

    isRunning = true;

    //repeats every 1 sec
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        // if time reamining, - 1 second
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else { // stop timer 
          timer.cancel();
          setState(() {
            isRunning = false;
          });
          saveCompletedSession(); // save session

          // check if there is more sessions left or no
          if (currentSession < widget.sessionCount) {
            // setState() {
              // currentSession++;
              // remainingSeconds = totalSeconds;
              // isRunning = false;

            // show if want to continue sessions or not
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      "Session $currentSession Completed!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    content: Text(
                      "Great job! Ready to continue your next study session?",
                      style: TextStyle(
                        color: AppColors.darkText,
                        height: 1.5,
                      ),
                    ),
                    actions: [
                      // give up
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Give Up Remaining Sessions",
                          style: TextStyle(
                            color: AppColors.alertPink,
                          ),
                        ),
                      ),
                      // continue next sesssion
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            currentSession++;
                            remainingSeconds = totalSeconds;
                            isRunning = false;
                          });
                        },
                        child: Text(
                          "Continue Session",
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            // all sessions completed
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      "All Sessions Completed WOOHOO!",
                    ),
                    content: Text(
                      "Great work! You have completed all study sessions!",
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);   // close dialog
                          Navigator.pop(context);   // back to dahsboard
                        },
                        child: Text("Back to Dashboard"),
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      },
    );
  }

  // pause timer
  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  // reset timer
  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;  // reset to original time
    });
  }

  // format the time to mm:ss 
  // ex: 185 seconds -> "03:05"
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;  // int division, 185 ~/ 60 = 3
    int secs = seconds % 60;  // remainder, 185 % 60 = 5
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}"; // padLeft ensure two digits like 05, X 5
  }

  // pomodoro UI
  @override
  Widget build(BuildContext context) {
    // calculate progress % for circular indicator
    // 1.0 - full circle, 0.0 = empty, 0.5 = half
    double progress = remainingSeconds / totalSeconds;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // top header (back button + study session title + logo)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // back btn w confirmation dialog to prevent exit and lose progress
                    IconButton(
                      onPressed: () {
                        showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              "Give up on this session?",
                            ),
                            content: Text(
                              "Leaving now means this session will not be included in your progress.",
                            ),
                            actions: [
                              // continue progress
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Keep Going"),
                              ),
                              // reset timer w/o saving progress & back to dashboard
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.alertPink,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);  //close dialog pop up first
                                  resetTimer();
                                  Navigator.pop(context); //move to student dashboard
                                },
                                child: Text(
                                  "Give Up Anyway",
                                  style: TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.darkText,
                      ),
                    ),

                    // title
                    Text(
                      "Study Session",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    // app logo
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/learnimalLogo.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // focus mode label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Focus Mode",
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // timer
                CircularPercentIndicator(
                  radius: 120,      // circle size
                  lineWidth: 10,    // thicknes
                  percent: progress,  // 0.0 to 1.0 based on remaining time
                  circularStrokeCap: CircularStrokeCap.round, // rounded ends so its circle shape
                  progressColor: AppColors.primaryBlue, // remaining time
                  backgroundColor: AppColors.lightGray, // elapsed time

                  // center time display (00:00)
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatTime(remainingSeconds),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Focus Time",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // display the animal & quotee
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // animal images
                    Image.asset(
                      widget.animalImage,
                      height: 130,
                    ),

                    // quote 
                    Container(
                      width: 160,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // quote txt
                        children: [
                          Text(
                            quote,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "- $author",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // buttons (traffic light buttons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StudentTimerButton(
                      icon: Icons.play_arrow,
                      label: "Start",
                      onTap: startTimer,
                      color: AppColors.successGreen,
                    ),

                    StudentTimerButton(
                      icon: Icons.pause,
                      label: "Pause",
                      onTap: pauseTimer,
                      color: AppColors.rewardYellow,
                    ),

                    StudentTimerButton(
                      icon: Icons.stop,
                      label: "End",
                      color: AppColors.alertPink,
                      onTap: () {
                        // show confirmation dialog bfr gicing up
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              title: Text(
                                "Give up on this session?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              content: Text(
                                "Leaving now means this session will not be included in your progress.\n\nYour focus progress will be lost.",
                                style: TextStyle(
                                  color: AppColors.darkText,
                                  height: 1.5,
                                ),
                              ),

                              actions: [
                                // continue button
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Keep Going",
                                    style: TextStyle(
                                      color:
                                          AppColors.primaryBlue,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // give up anyway button
                                ElevatedButton(
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.alertPink,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    resetTimer();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Give Up Anyway",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // session card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // left: session counter (ex: 1/2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Session",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$currentSession / ${widget.sessionCount}",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      // right: focus time duration (15 min)
                      Text(
                        "${widget.focusTime} min",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // buttons
  Widget timerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
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