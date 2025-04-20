import 'package:attendence_app/services/database_service.dart';
import 'package:flutter/material.dart';

class AddCommitteeMemberScreen extends StatefulWidget {
  const AddCommitteeMemberScreen({super.key});

  @override
  State<AddCommitteeMemberScreen> createState() =>
      _AddCommitteeMemberScreenState();
}

class _AddCommitteeMemberScreenState extends State<AddCommitteeMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _addMember() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      String name = _nameController.text;
      String username = _usernameController.text;
      String password = _passwordController.text;

      bool success = await _databaseService.addCommitteeMember(
        name: name,
        username: username,
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Committee Member Added Successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to add member. Username might exist or server error.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Committee Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter New Member Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController, // Controller for name
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (for login)',
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Set Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        value!.isEmpty || value.length < 4
                            ? 'Password must be at least 4 characters'
                            : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  )
                  : ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                    onPressed: _addMember,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
