// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart'; // For kDebugMode

// class DatabaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late final CollectionReference _usersCollection;

//   DatabaseService() {
//     _usersCollection = _firestore.collection('users');
//   }

//   // --- Security Warning ---
//   // The password should be securely hashed BEFORE calling this function.
//   // Do NOT store plain text passwords in production.
//   // ---

//   Future<bool> addUser({
//     required String name,
//     required String username,
//     required String password, // Should be HASHED password
//     required String type, // 'committee_mem' or 'employee'
//   }) async {
//     try {
//       // Check if username already exists (optional but recommended)
//       QuerySnapshot existingUser =
//           await _usersCollection
//               .where('uname', isEqualTo: username)
//               .limit(1)
//               .get();

//       if (existingUser.docs.isNotEmpty) {
//         if (kDebugMode) {
//           print('Username $username already exists.');
//         }
//         // You might want to throw a specific exception or return a different indicator
//         return false; // Indicate failure due to existing username
//       }

//       // Prepare user data map matching your Firestore structure
//       Map<String, dynamic> userData = {
//         'name': name,
//         'uname': username,
//         'password':
//             password, // Storing plain text - VERY INSECURE FOR PRODUCTION
//         'type': type,
//         // Optional: Add a timestamp
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       // Add the user document to the 'users' collection
//       await _usersCollection.add(userData);

//       if (kDebugMode) {
//         print('User added successfully: $username ($type)');
//       }
//       return true; // Indicate success
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error adding user ($username): $e');
//       }
//       return false; // Indicate failure
//     }
//   }

//   // Specific function for adding a Committee Member
//   Future<bool> addCommitteeMember({
//     required String name,
//     required String username,
//     required String password, // Should be HASHED password
//   }) async {
//     // **TODO: Implement password hashing here or before calling**
//     // Example (using a hypothetical hashPassword function):
//     // String hashedPassword = await hashPassword(password);
//     String unsafePassword = password; // Replace with hashed password

//     return await addUser(
//       name: name,
//       username: username,
//       password: unsafePassword, // Pass the (ideally hashed) password
//       type: 'commitee_mem', // Use the exact type string from your screenshot
//     );
//   }

//   // Specific function for adding an Employee
//   Future<bool> addEmployee({
//     required String name,
//     required String username, // Assuming 'uname' is used for employee login too
//     required String password, // Should be HASHED password
//     // Add other employee specific fields if needed (e.g., employeeId)
//   }) async {
//     // **TODO: Implement password hashing here or before calling**
//     String unsafePassword = password; // Replace with hashed password

//     return await addUser(
//       name: name,
//       username: username,
//       password: unsafePassword, // Pass the (ideally hashed) password
//       type: 'employee', // Assuming 'employee' is the type string
//       // Add other employee specific fields to the map inside addUser if needed
//     );
//   }

//   // --- Placeholder for Hashing ---
//   // Future<String> hashPassword(String password) async {
//   //   // Use a library like 'crypto' to hash the password securely
//   //   // Example using crypto (add crypto package to pubspec.yaml)
//   //   // var bytes = utf8.encode(password); // Convert password to bytes
//   //   // var digest = sha256.convert(bytes); // Hash using SHA-256
//   //   // return digest.toString(); // Return the hashed string
//   //   print("WARNING: Password hashing not implemented. Storing plain text.");
//   //   return password; // Returning plain text TEMPORARILY
//   // }
//   // ---

//   Future<bool> verifyUser(String role, String username, String password) async {
//     try {
//       QuerySnapshot querySnapshot =
//           await _usersCollection
//               .where('uname', isEqualTo: username)
//               .where(
//                 'type',
//                 isEqualTo: (role == 'committee' ? 'commitee_mem' : 'employee'),
//               )
//               .limit(1)
//               .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // --- SECURITY WARNING ---
//         // In a real application, you MUST compare the provided password
//         // with the HASHED password stored in the database.
//         // DO NOT compare plain text passwords.
//         // ---
//         String storedPassword = querySnapshot.docs.first['password'];
//         if (storedPassword == password) {
//           return true; // Credentials match (INSECURE PLAIN TEXT COMPARISON)
//         }
//       }
//       return false; // User not found or password doesn't match
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error verifying user ($username): $e');
//       }
//       return false; // Error during verification
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;

  DatabaseService() {
    _usersCollection = _firestore.collection('users');
  }

  Future<bool> addUser({
    required String name,
    required String username,
    required String password,
    required String type,
    String? category,
  }) async {
    try {
      QuerySnapshot existingUser =
          await _usersCollection
              .where('uname', isEqualTo: username)
              .limit(1)
              .get();

      if (existingUser.docs.isNotEmpty) {
        if (kDebugMode) {
          print('Username $username already exists.');
        }
        return false;
      }

      Map<String, dynamic> userData = {
        'name': name,
        'uname': username,
        'password': password,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        if (category != null) 'category': category,
      };

      await _usersCollection.add(userData);

      if (kDebugMode) {
        print(
          'User added successfully: $username ($type, category: $category)',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding user ($username): $e');
      }
      return false;
    }
  }

  Future<bool> addCommitteeMember({
    required String name,
    required String username,
    required String password,
    String? category,
  }) async {
    String unsafePassword = password;
    return await addUser(
      name: name,
      username: username,
      password: unsafePassword,
      type: 'commitee_mem',
      category: category,
    );
  }

  Future<bool> addEmployee({
    required String name,
    required String username,
    required String password,
    String? category,
  }) async {
    String unsafePassword = password;
    return await addUser(
      name: name,
      username: username,
      password: unsafePassword,
      type: 'employee',
      category: category,
    );
  }

  Future<bool> verifyUser(String role, String username, String password) async {
    try {
      QuerySnapshot querySnapshot =
          await _usersCollection
              .where('uname', isEqualTo: username)
              .where(
                'type',
                isEqualTo: (role == 'committee' ? 'commitee_mem' : 'employee'),
              )
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String storedPassword = querySnapshot.docs.first['password'];
        if (storedPassword == password) {
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying user ($username): $e');
      }
      return false;
    }
  }
}
