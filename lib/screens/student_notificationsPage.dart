import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../repositories/student_notifications_repository.dart';

class StudentNotificationsPage extends StatelessWidget {
  StudentNotificationsPage({super.key});

  final StudentNotificationsRepository repository = StudentNotificationsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // top header (title)
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // body: real time not list from firebase
      body: StreamBuilder<QuerySnapshot>( // listens to firebase collection changes + automatically rebuild UI when data changes 
        // real-time connection to notif collection
        stream: FirebaseFirestore.instance
            .collection("notifications")
            //.where("studentId", isEqualTo: currentStudentId,) // READ FROM LOGIN
            .orderBy("createdAt", descending: true,)  // newest notif first
            .snapshots(), // returns a stream that emits updates automatically

        // rebuilds UI when data changes
        builder: (context, snapshot) {
          // if not data
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(), // load spinner
            );
          }

          // extract list of notif doc
          final docs = snapshot.data!.docs;

          // if empty then put no notif
          if (docs.isEmpty) {
            return Center(

              child: Text(
                "No notifications yet.",
              ),
            );
          }

          // if data available build a notif card
          return ListView.builder(
            itemCount: docs.length, // num of notif
            itemBuilder: (context, index) {

              final notification = docs[index]; // get individual notif doc
              
              final data = notification.data() as Map<String, dynamic>; // convert to map

              // notif card UI
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16, // left right margin
                  vertical: 10, // top / bottom margin
                ),
                // inside card
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Row(
                  children: [
                    // left: txt content (title + msg)
                    Expanded( 
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // notif title
                          Text(
                            data["title"],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 8), // gap between title + card)
                          Text(
                            data["message"],
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // right: delete btn
                    IconButton(
                      onPressed: () async {
                        await repository.deleteNotification(notification.id,);
                      },
                      icon: Icon(
                        Icons.delete_outline, // trash can icon
                        color:AppColors.alertPink,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}