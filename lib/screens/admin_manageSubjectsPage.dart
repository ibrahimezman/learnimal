import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../repositories/admin_repository.dart';

class AdminManageSubjectsPage extends StatefulWidget {
  const AdminManageSubjectsPage({super.key});

  @override
  State<AdminManageSubjectsPage> createState() =>
      _AdminManageSubjectsPageState();
}

class _AdminManageSubjectsPageState extends State<AdminManageSubjectsPage> {
  final _repository = AdminRepository();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // show single subject form dialog (handles both Add and Edit dynamically)
  void _showSubjectFormDialog({
    String? docId,
    String? currentName,
    String? currentCode,
  }) {
    final bool isEditing = docId != null;
    _nameController.text = currentName ?? "";
    _codeController.text = currentCode ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditing ? "Edit Subject" : "Add New Subject",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Subject Name",
                  prefixIcon: Icon(Icons.book, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: "Subject Code",
                  prefixIcon: Icon(Icons.code, color: AppColors.primaryBlue),
                ),
              ),
            ],
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
                final code = _codeController.text.trim();

                if (name.isEmpty || code.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required!")),
                  );
                  return;
                }

                if (isEditing) {
                  await _repository.updateSubject(
                    docId: docId,
                    name: name,
                    code: code,
                  );
                } else {
                  await _repository.addSubject(name: name, code: code);
                }

                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.successGreen,
                    content: Text(
                      isEditing
                          ? "Subject updated successfully!"
                          : "Subject added successfully!",
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
  }

  // delete subject dialog check
  void _confirmDeleteSubject(String docId, String subjectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Subject"),
        content: Text(
          "Are you sure you want to permanently delete $subjectName?",
        ),
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
              await _repository.deleteSubject(docId);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Subject deleted successfully.")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
                "School Curriculum Subjects",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _repository.getSubjectsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No subjects created yet.\nClick '+' to add one!",
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
                        final code = data["code"] ?? "N/A";

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
                                Icons.menu_book,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.darkText,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.tag,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    code,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
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
                                  onPressed: () => _showSubjectFormDialog(
                                    docId: doc.id,
                                    currentName: name,
                                    currentCode: code,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.alertPink,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteSubject(doc.id, name),
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
        onPressed: () => _showSubjectFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
