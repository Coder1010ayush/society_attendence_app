import 'package:flutter/material.dart';

class CommitteeDashboardScreen extends StatelessWidget {
  const CommitteeDashboardScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Committee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildDashboardCard(
            context,
            icon: Icons.person_add_alt_1,
            title: 'Add Committee Member',
            subtitle: 'Register a new member in the committee',
            onTap: () {
              Navigator.pushNamed(context, '/add_committee_member');
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            icon: Icons.group_add,
            title: 'Add Employee',
            subtitle: 'Register a new employee',
            onTap: () {
              Navigator.pushNamed(context, '/add_employee');
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            icon: Icons.event_available,
            title: 'View Employee Attendance',
            subtitle: 'Check attendance records of employees',
            onTap: () {
              Navigator.pushNamed(context, '/view_employee_attendance');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Icon(icon, size: 40.0, color: Theme.of(context).hintColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),
      ),
    );
  }
}
