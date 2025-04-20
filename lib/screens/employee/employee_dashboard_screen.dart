import 'package:flutter/material.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  final String uname;

  const EmployeeDashboardScreen({super.key, required this.uname});

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
        title: const Text('Employee Dashboard'),
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
            icon: Icons.fingerprint,
            title: 'Mark Attendance',
            subtitle: 'Mark your attendance for today',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/mark_attendance',
                arguments: uname,
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            icon: Icons.history,
            title: 'View My Attendance',
            subtitle: 'Check your past attendance records',
            onTap: () {
              print(uname);
              Navigator.pushNamed(
                context,
                '/view_my_attendance',
                arguments: uname,
              );
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
