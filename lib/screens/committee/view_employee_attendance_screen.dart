// import 'package:flutter/material.dart';

// class ViewEmployeeAttendanceScreen extends StatelessWidget {
//   const ViewEmployeeAttendanceScreen({super.key});

//   // TODO: Add state and logic to fetch and display attendance data

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Employee Attendance'),
//         // Add filtering options (date range, specific employee) here if needed
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             tooltip: 'Filter Attendance',
//             onPressed: () {
//               // TODO: Implement filter dialog/logic
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Filter Placeholder'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
// const Icon(
//   Icons.calendar_today,
//   size: 50,
//   color: Colors.tealAccent,
// ),
// const SizedBox(height: 20),
//               Text(
//                 'Employee attendance records will be displayed here.',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 20),
//               // TODO: Replace with actual list view of attendance data
//               const Text('(Placeholder List)'),
//               Expanded(
//                 child: ListView.builder(
//                   // Example List
//                   itemCount: 5, // Placeholder count
//                   itemBuilder: (context, index) {
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 5),
//                       child: ListTile(
//                         leading: CircleAvatar(child: Text('${index + 1}')),
//                         title: Text('Employee Name ${index + 1}'),
//                         subtitle: Text(
//                           'Date: 2025-04-${18 - index} - Status: Present',
//                         ), // Example data
//                         trailing: Icon(Icons.check_circle, color: Colors.green),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class ViewEmployeeAttendanceScreen extends StatefulWidget {
  const ViewEmployeeAttendanceScreen({super.key});

  @override
  State<ViewEmployeeAttendanceScreen> createState() =>
      _ViewEmployeeAttendanceScreenState();
}

class _ViewEmployeeAttendanceScreenState
    extends State<ViewEmployeeAttendanceScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLast7DaysAttendance();
  }

  Future<void> _fetchLast7DaysAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _attendanceData = [];
    });

    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final attendanceCollection = FirebaseFirestore.instance.collection(
        'attendance',
      );

      final querySnapshot =
          await attendanceCollection
              .where(
                'attend',
                isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
              )
              .where('attend', isLessThanOrEqualTo: Timestamp.fromDate(now))
              .orderBy('attend', descending: true)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        _attendanceData =
            querySnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'employeeName': data['uname'] ?? 'N/A',
                'attendanceTime': (data['attend'] as Timestamp).toDate(),
                'status': data['status'] ?? 'Present',
              };
            }).toList();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to fetch attendance data: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Employee Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Attendance',
            onPressed: _fetchLast7DaysAttendance,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Attendance',
            onPressed: () {
              // TODO: Implement filter dialog/logic (date range, specific employee)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter Placeholder'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _attendanceData.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'No attendance records found for the last 7 days.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: const Icon(
                        Icons.calendar_today,
                        size: 50,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Attendance Records (Last 7 Days)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _attendanceData.length,
                        itemBuilder: (context, index) {
                          final attendance = _attendanceData[index];
                          final formattedDate = DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(attendance['attendanceTime']);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(attendance['employeeName'] ?? 'N/A'),
                              subtitle: Text(
                                'Date/Time: $formattedDate - Status: ${attendance['status']}',
                              ),
                              trailing: Icon(
                                attendance['status'] == 'Present'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    attendance['status'] == 'Present'
                                        ? Colors.green
                                        : Colors.redAccent,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
