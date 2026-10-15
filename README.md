# Learnimal

**CT088-3-2-MAE | Dart/Flutter | Group Project (Group 6)**

A mobile learning application for teachers, students, and administrators with study tracking, classroom management, and goal setting.

## Overview

Learnimal is a cross-platform mobile application built with Flutter for the Mobile App Engineering course. The app supports three user roles (Teacher, Student, Admin) with features including study session tracking (Pomodoro), classroom management, goal setting, progress monitoring, feedback collection, and administrative analytics.

**My Contribution**: Teacher role implementation including login authentication, teacher dashboard, classroom management, analytics, feedback system, and student profile viewing.

## Features

### Authentication (All Roles)
- **Login System**: Role-based authentication using Firebase
- **Role Detection**: Automatic routing to role-specific dashboards (Teacher, Student, Admin)
- **Session Management**: Persistent login state with logout functionality

### Teacher Features (My Implementation)
- **Teacher Dashboard**: Real-time classroom overview with Pomodoro controls
- **Classroom Management**: Select classrooms, view enrolled students, gift rewards
- **Analytics**: Session-by-day and session-by-hour charts with KPIs
- **Feedback System**: Send personalized feedback to students
- **Student Profiles**: View individual student study history and session data
- **Live Activity Feed**: Monitor which students are currently studying
- **Pomodoro Control**: Start/stop group study sessions for the classroom

### Student Features
- Dashboard with study overview
- Pomodoro timer for focused study sessions
- Goal setting and tracking
- Progress visualization
- Notifications

### Admin Features
- User management
- Subject management
- Statistics and analytics
- System oversight

### Firebase Integration
- Authentication, cloud services, and real-time data

## Tech Stack

- **Language**: Dart
- **Framework**: Flutter
- **State Management**: Provider / Riverpod (project-dependent)
- **Backend**: Firebase (Auth, Firestore, etc.)
- **Platforms**: Android, iOS, Web, Windows, Linux, macOS

## Project Structure

```
lib/
  main.dart                  — Application entry point
  constants/app_colors.dart   — App color constants
  models/
    classrooms.dart           — Classroom data model
    feedback.dart             — Feedback data model
    study_sessions.dart       — Study session data model
  repositories/
    admin_repository.dart     — Admin data operations
    classroom_repository.dart — Classroom data operations
    feedback_repository.dart  — Feedback data operations
    goals_repository.dart     — Goals data operations
    reward_repository.dart    — Rewards data operations
    student_repository.dart   — Student data operations
    study_repository.dart     — Study data operations
    teacher_repository.dart   — Teacher data operations
  screens/
    login_page.dart           — Authentication screen (My contribution)
    admin_dashboard.dart      — Admin main screen
    admin_manageSubjectsPage.dart
    admin_manageUsersPage.dart
    admin_profilePage.dart
    admin_statisticsPage.dart
    student_dashboard.dart    — Student main screen
    student_goalsPage.dart
    student_notificationsPage.dart
    student_pomodoroPage.dart
    student_progressPage.dart
    teacher_dashboard.dart    — Teacher main screen (My contribution)
    teacher_analytics.dart    — Analytics dashboard (My contribution)
    teacher_classroom.dart    — Classroom management (My contribution)
    teacher_feedback.dart     — Feedback system (My contribution)
    teacher_studentview.dart  — Student profile viewer (My contribution)
  widgets/
    student_goal_card.dart
    student_progress_bar.dart
    student_timer_button.dart
    teacher_classroom_dropdown.dart
    teacher_pomodoro_panel.dart
    teacher_sidebar.dart
android/                     — Android platform files
ios/                         — iOS platform files
web/                         — Web platform files
linux/                       — Linux platform files
macos/                       — macOS platform files
windows/                     — Windows platform files
firebase.json                — Firebase configuration
pubspec.yaml                 — Flutter dependencies
```

## Prerequisites

- Flutter SDK (3.0 or later)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase project setup

## Build & Run

```bash
# Check Flutter setup
flutter doctor

# Run on connected device/emulator
flutter run

# Run with specific target
flutter run -d chrome  # Web
flutter run -d windows  # Windows
flutter run -d android  # Android
```

## Usage

### Login
1. Launch the app and log in with your credentials
2. The system detects your role and routes you to the appropriate dashboard

### Teacher Workflow
1. **Dashboard**: Select a classroom from the dropdown to view enrolled students
2. **Analytics**: View session-by-day and session-by-hour charts with KPIs
3. **Classroom Management**: Gift rewards to students, view student profiles
4. **Feedback**: Send personalized feedback messages to students
5. **Pomodoro Control**: Start group study sessions and monitor live activity

## Concepts / Design Notes

### Architecture

The app follows a repository pattern for data management:
- **Repositories**: Abstract data access layer for each entity type
- **Models**: Data classes for domain entities
- **Screens**: Feature-specific UI screens
- **Widgets**: Reusable UI components

### Firebase Integration

- Firebase Authentication for user management
- Firestore for data persistence
- Firebase Messaging for push notifications
- Firebase configuration in `firebase_options.dart`

### Teacher Role Design

The teacher role is built around real-time classroom management:
- **Stream-based UI**: Real-time updates for student activity and session data
- **Role-based routing**: Login page routes users to role-specific dashboards
- **Classroom-centric**: All teacher features are organized around selected classrooms
- **Gamification**: Reward system for student engagement

## Author

Ibrahim Bin Mohd Ezman, APU (Group 6)

## License

This project is licensed under the MIT License.
