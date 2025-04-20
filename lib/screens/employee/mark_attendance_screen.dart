import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:attendence_app/services/attendance_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final DatabaseServiceAttend _databaseService = DatabaseServiceAttend();
  bool _alreadyMarked = false;
  bool _isLoading = true;
  bool _isMarking = false;
  String _statusMessage = 'Checking attendance status...';
  String? _employeeUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _employeeUsername = args;
        });
        _checkInitialAttendanceStatus();
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error: Employee details not found.';
          _alreadyMarked = true;
        });
        print(
          "Error: Employee username not passed as argument to MarkAttendanceScreen",
        );
      }
    });
  }

  Future<void> _checkInitialAttendanceStatus() async {
    if (_employeeUsername == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking attendance status...';
    });

    bool marked = await _databaseService.hasMarkedAttendanceToday(
      _employeeUsername!,
    );

    if (mounted) {
      setState(() {
        _alreadyMarked = marked;
        _isLoading = false;
        _statusMessage =
            marked
                ? 'Attendance already marked for today.'
                : 'Ready to mark attendance for today.';
      });
    }
  }

  Future<void> _markAttendance() async {
    debugPrint(_employeeUsername);
    if (_employeeUsername == null || _alreadyMarked || _isMarking) return;

    setState(() {
      _isMarking = true;
      _statusMessage = 'Marking attendance...';
    });

    String result = await _databaseService.markAttendance(_employeeUsername!);

    if (mounted) {
      setState(() {
        _isMarking = false;
        switch (result) {
          case "Success":
            _alreadyMarked = true;
            _statusMessage = 'Attendance marked successfully for today!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_statusMessage),
                backgroundColor: Colors.green,
              ),
            );
            break;
          case "AlreadyMarked":
            _alreadyMarked = true;
            _statusMessage = 'Attendance already marked for today.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_statusMessage),
                backgroundColor: Colors.orangeAccent,
              ),
            );
            break;
          case "Error":
          default:
            _statusMessage = 'Failed to mark attendance. Please try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_statusMessage),
                backgroundColor: Colors.redAccent,
              ),
            );
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());
    final bool canMark =
        _employeeUsername != null &&
        !_alreadyMarked &&
        !_isLoading &&
        !_isMarking;

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                todayDate,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.tealAccent),
              ),
              if (_employeeUsername != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'User: $_employeeUsername',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                  ),
                ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: CircularProgressIndicator(
                        color: Colors.tealAccent,
                      ),
                    ),
                  )
                  : Icon(
                    _alreadyMarked
                        ? Icons.check_circle_outline
                        : Icons.touch_app_outlined,
                    size: 80,
                    color: _alreadyMarked ? Colors.green : Colors.tealAccent,
                  ),
              const SizedBox(height: 20),

              // Status Message
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _alreadyMarked ? Colors.green : Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              _isMarking
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  )
                  : ElevatedButton.icon(
                    icon: Icon(
                      _alreadyMarked ? Icons.check_circle : Icons.fingerprint,
                    ),
                    label: Text(
                      _alreadyMarked ? 'Attendance Marked' : 'Mark Me Present',
                    ),
                    onPressed: canMark ? _markAttendance : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: canMark ? Colors.teal : Colors.grey[700],
                      foregroundColor: canMark ? Colors.white : Colors.white54,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
