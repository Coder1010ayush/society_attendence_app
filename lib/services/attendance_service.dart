import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class DatabaseServiceAttend {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _attendanceCollection;

  DatabaseServiceAttend() {
    _attendanceCollection = _firestore.collection(
      'attendence',
    ); // Initialize attendance collection
  }

  /// Marks attendance for a given employee username.
  ///
  /// Checks if attendance has already been marked for the user today.
  /// If not, adds a new attendance record.
  ///
  /// Returns:
  /// - "Success" if attendance was marked successfully.
  /// - "AlreadyMarked" if attendance was already marked today for this user.
  /// - "Error" if any other error occurred.
  Future<String> markAttendance(String employeeUsername) async {
    debugPrint("markAttendance called for user: $employeeUsername");
    try {
      debugPrint("yagooo - Entering try block");
      // 1. Calculate Start and End of Today (in UTC for Firestore)
      DateTime now = DateTime.now();
      debugPrint("Current local time: $now");
      // Start of today (00:00:00)
      DateTime startOfDayLocal = DateTime(now.year, now.month, now.day);
      debugPrint("Start of today (local): $startOfDayLocal");
      // Start of next day (00:00:00)
      DateTime startOfNextDayLocal = DateTime(now.year, now.month, now.day + 1);
      debugPrint("Start of next day (local): $startOfNextDayLocal");

      // Convert to Firestore Timestamps (which are timezone-aware, typically handled as UTC)
      // Firestore queries compare timestamps directly. Using local start/end times converted
      // to Timestamps works correctly for finding documents within that day UTC.
      Timestamp startOfDayTimestamp = Timestamp.fromDate(
        startOfDayLocal.toUtc(),
      );
      debugPrint("Start of today (UTC Timestamp): $startOfDayTimestamp");
      Timestamp startOfNextDayTimestamp = Timestamp.fromDate(
        startOfNextDayLocal.toUtc(),
      );
      debugPrint("Start of next day (UTC Timestamp): $startOfNextDayTimestamp");

      // 2. Check if attendance already exists for this user today
      if (kDebugMode) {
        print(
          'Checking attendance for $employeeUsername between $startOfDayLocal (local) and $startOfNextDayLocal (local)',
        );
        print(
          'Querying Firestore for attendance between $startOfDayTimestamp (UTC) and $startOfNextDayTimestamp (UTC)',
        );
      }
      debugPrint("Attempting to query _attendanceCollection");
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection(
                'attendance',
              ) // Assuming '_attendanceCollection' refers to 'attendance'
              .where('uname', isEqualTo: employeeUsername)
              .where('attend', isGreaterThanOrEqualTo: startOfDayTimestamp)
              .where('attend', isLessThan: startOfNextDayTimestamp)
              .limit(1) // We only need to know if at least one exists
              .get();
      debugPrint(
        "Firestore query completed. Number of documents found: ${querySnapshot.docs.length}",
      );
      debugPrint("nkfsnjbfjbj - Query successful");

      // 3. If no record exists, add a new one
      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'No attendance found for $employeeUsername today. Marking present.',
          );
        }
        // Prepare the data for the new attendance record
        Map<String, dynamic> attendanceData = {
          'uname': employeeUsername,
          'attend':
              FieldValue.serverTimestamp(), // Use server timestamp for accuracy
          // Add any other relevant fields if needed (e.g., status: 'Present')
          'status': 'Present', // Added a potential relevant field
          'markedAtLocal': now.toString(), // Logging local time of marking
          'markedAtUTC': now.toUtc().toString(), // Logging UTC time of marking
        };
        debugPrint("Attendance data to be added: $attendanceData");
        debugPrint("school ka bachha hua kidnap - Preparing to add data");

        // Add the document
        DocumentReference addedDocument = await FirebaseFirestore.instance
            .collection(
              'attendance',
            ) // Assuming '_attendanceCollection' refers to 'attendance'
            .add(attendanceData);
        debugPrint(
          'Attendance marked successfully for $employeeUsername. Document ID: ${addedDocument.id}',
        );
        return "Success";
      }
      // 4. If a record already exists
      else {
        if (kDebugMode) {
          debugPrint('Attendance already marked for $employeeUsername today.');
        }
        return "AlreadyMarked";
      }
    } catch (e) {
      if (kDebugMode) {
        print(kDebugMode);
        debugPrint('Error marking attendance for $employeeUsername: $e');
      }
      return "Error"; // Indicate failure
    }
  }

  /// Checks if attendance has already been marked for the user today.
  /// (Helper function primarily for initializing the UI state)
  Future<bool> hasMarkedAttendanceToday(String employeeUsername) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDayLocal = DateTime(now.year, now.month, now.day);
      DateTime startOfNextDayLocal = DateTime(now.year, now.month, now.day + 1);
      Timestamp startOfDayTimestamp = Timestamp.fromDate(startOfDayLocal);
      Timestamp startOfNextDayTimestamp = Timestamp.fromDate(
        startOfNextDayLocal,
      );

      QuerySnapshot querySnapshot =
          await _attendanceCollection
              .where('uname', isEqualTo: employeeUsername)
              .where('attend', isGreaterThanOrEqualTo: startOfDayTimestamp)
              .where('attend', isLessThan: startOfNextDayTimestamp)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking attendance status for $employeeUsername: $e');
      }
      return false; // Assume not marked if error occurs during check
    }
  }
}
