import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../repositories/admin_repository.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String loggedInEmail = "";
  static String loggedInStudentId = "";
  static String loggedInTeacherId = "";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repository = AdminRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // route authenticated user by role and pass their email
  void _routeUser(String role, String email) {
    if (!context.mounted) return;

    Widget dashboard;
    if (role == 'Admin') {
      dashboard = AdminDashboard(email: email);
    } else if (role == 'Teacher') {
      dashboard = TeacherDashboard();
    } else {
      dashboard = const StudentDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        content: Text(
          "Logged in successfully as ${role.toUpperCase()}",
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // handle sign in checks
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // 1. try Firestore direct login first
      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // save current logged in student ID
        LoginPage.loggedInStudentId = query.docs.first.id;

        final doc = query.docs.first;
        final role = doc.get("role") ?? "Student";

        LoginPage.loggedInEmail = email;

        if (role == "Student") {
          LoginPage.loggedInStudentId = doc.id;
        }
        else if (role == "Teacher") {
          LoginPage.loggedInTeacherId = doc.id;
        }

        _routeUser(role, email);
      } else {
        // 2. fallback to Firebase Auth
        try {
          final credentials = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          if (credentials.user != null) {
            final role = await _repository.getUserRole(email);
            _routeUser(role, email);
          }
        } on FirebaseAuthException catch (e) {
          if (!context.mounted) return;
          String err = "Incorrect email or password.";
          if (e.code == 'invalid-email') err = "Invalid email format.";

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Authentication Failed"),
              content: Text(err),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Error: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/learnimalLogo.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (c, e, s) => Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school,
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome to Learnimal",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to access your dashboard",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            hintText: "example@learnimal.com",
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryBlue,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? "Please enter your email"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "••••••••",
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primaryBlue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Please enter your password"
                              : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}