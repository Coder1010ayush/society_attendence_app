import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewMyAttendanceScreen extends StatefulWidget {
  const ViewMyAttendanceScreen({super.key});

  @override
  State<ViewMyAttendanceScreen> createState() => _ViewMyAttendanceScreenState();
}

class _ViewMyAttendanceScreenState extends State<ViewMyAttendanceScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = true;
  String? _errorMessage;
  late String _uname;
  bool _isUnameInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isUnameInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _uname = args;
        print('ViewMyAttendanceScreen received uname: $_uname');
        _fetchLastMonthAttendance();
        _isUnameInitialized = true;
      } else {
        _errorMessage = 'Error: Username not provided.';
        _isLoading = false;
      }
    }
  }

  Future<void> _fetchLastMonthAttendance() async {
    print('Fetching attendance for uname: $_uname');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _attendanceData = [];
    });

    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));
    print('Now: ${now.toIso8601String()}');
    print('One Month Ago: ${oneMonthAgo.toIso8601String()}');

    try {
      final attendanceCollection = FirebaseFirestore.instance.collection(
        'attendance',
      );

      final nowUtc = now.toUtc();
      final oneMonthAgoUtc = oneMonthAgo.toUtc();

      final querySnapshot =
          await attendanceCollection
              .where('uname', isEqualTo: _uname)
              .where(
                'attend',
                isGreaterThanOrEqualTo: Timestamp.fromDate(oneMonthAgoUtc),
              )
              .where('attend', isLessThanOrEqualTo: Timestamp.fromDate(nowUtc))
              .orderBy('attend', descending: true)
              .get();

      print('Number of documents found: ${querySnapshot.docs.length}');
      if (querySnapshot.docs.isNotEmpty) {
        print('First few documents:');
        for (int i = 0; i < min(3, querySnapshot.docs.length); i++) {
          print(querySnapshot.docs[i].data());
        }
        _attendanceData =
            querySnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'attendanceTime': (data['attend'] as Timestamp).toDate(),
                'status': data['status'] ?? 'Present',
              };
            }).toList();
      }
    } catch (error) {
      print('Error fetching attendance data: $error');
      setState(() {
        _errorMessage = 'Failed to fetch your attendance data: $error';
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
        title: const Text('My Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Attendance',
            onPressed: _fetchLastMonthAttendance,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Attendance',
            onPressed: () {
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
                      'No attendance records found for the last month.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Your Attendance History (Last Month)',
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
                              leading: Icon(
                                attendance['status'] == 'Present'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    attendance['status'] == 'Present'
                                        ? Colors.green
                                        : Colors.redAccent,
                              ),
                              title: Text('Date: $formattedDate'),
                              subtitle: Text('Status: ${attendance['status']}'),
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
