import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../repositories/admin_repository.dart';

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({super.key});

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  final _repository = AdminRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRole = "Student";
  final List<String> _roles = ["Admin", "Student", "Teacher"];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // add or edit user
  void _showUserFormDialog({
    String? docId,
    String? currentName,
    String? currentEmail,
    String? currentRole,
  }) {
    final bool isEditing = docId != null;
    _nameController.text = currentName ?? "";
    _emailController.text = currentEmail ?? "";

    // normalize user roles to match capitalization options
    String normalizedRole = "Student";
    if (currentRole != null) {
      if (currentRole.toLowerCase() == "admin") normalizedRole = "Admin";
      if (currentRole.toLowerCase() == "teacher") normalizedRole = "Teacher";
    }
    _selectedRole = normalizedRole;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? "Edit User Details" : "Add New User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "User Role:  ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            items: _roles
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => _selectedRole = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();

                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All fields are required!"),
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      await _repository.updateUser(
                        docId: docId,
                        name: name,
                        email: email,
                        role: _selectedRole,
                      );
                    } else {
                      await _repository.addUser(
                        name: name,
                        email: email,
                        role: _selectedRole,
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.successGreen,
                        content: Text(
                          isEditing
                              ? "User updated successfully!"
                              : "User added successfully!",
                          style: const TextStyle(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(isEditing ? "Update" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // delete user check dialog
  void _confirmDeleteUser(String docId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to permanently delete $userName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertPink,
              foregroundColor: AppColors.darkText,
            ),
            onPressed: () async {
              await _repository.deleteUser(docId);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User deleted successfully.")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // tag color indicator
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.alertPink;
      case 'teacher':
        return AppColors.rewardYellow;
      case 'student':
        return AppColors.successGreen;
      default:
        return AppColors.lightGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Registered Users",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _repository.getUsersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No users registered yet.\nClick '+' to add one!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data["name"] ?? "No Name";
                        final email = data["email"] ?? "No Email";
                        final role = data["role"] ?? "Student";

                        return Card(
                          color: AppColors.white,
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(
                                      role,
                                    ).withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                email,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.primaryBlue,
                                  ),
                                  onPressed: () => _showUserFormDialog(
                                    docId: doc.id,
                                    currentName: name,
                                    currentEmail: email,
                                    currentRole: role,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.alertPink,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteUser(doc.id, name),
                                ),
                              ],
                            ),
                          ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 2,
        onPressed: () => _showUserFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
