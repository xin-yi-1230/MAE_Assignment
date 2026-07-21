import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authenticationChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Public registration is only available to visitors and booth owners.
  ///
  /// Organizer and operation-staff accounts must be created by an
  /// administrator or organizer.
  Future<void> registerPublicUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    const allowedPublicRoles = {
      'visitor',
      'boothOwner',
    };

    if (!allowedPublicRoles.contains(role)) {
      throw const AuthFailure(
        'This account type cannot be registered publicly.',
      );
    }

    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthFailure('The account could not be created.');
      }

      await user.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': user.email ?? email.trim(),
        'role': role,
        'isActive': true,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Remove the Authentication account when its Firestore
      // profile cannot be created.
      final createdUser = credential?.user;

      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // Keep the original exception.
        }
      }

      rethrow;
    }
  }

  /// Normal login for visitors, booth owners and operation staff.
  ///
  /// An organizer attempting to use this page will be redirected
  /// to the separate organizer login page.
  Future<void> signInStandardUser({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw const AuthFailure('The account could not be authenticated.');
    }

    try {
      final profile = await _getUserProfile(user.uid);
      final role = profile['role'] as String?;
      final isActive = profile['isActive'] as bool? ?? true;

      if (!isActive) {
        throw const AuthFailure(
          'This account has been disabled. Please contact the organizer.',
        );
      }

      if (role == 'organizer') {
        throw const AuthFailure(
          'Organizer accounts must use Organizer Login.',
        );
      }

      const normalRoles = {
        'visitor',
        'boothOwner',
        'operationStaff',
      };

      if (!normalRoles.contains(role)) {
        throw const AuthFailure(
          'This account does not have a valid user role.',
        );
      }
    } catch (error) {
      await _auth.signOut();
      rethrow;
    }
  }

  /// Special organizer login.
  ///
  /// Email and password must be valid, and the Firestore user document
  /// must contain role: organizer.
  Future<void> signInOrganizer({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw const AuthFailure('The account could not be authenticated.');
    }

    try {
      final profile = await _getUserProfile(user.uid);
      final role = profile['role'] as String?;
      final isActive = profile['isActive'] as bool? ?? true;

      if (!isActive) {
        throw const AuthFailure(
          'This organizer account has been disabled.',
        );
      }

      if (role != 'organizer') {
        throw const AuthFailure(
          'This account is not registered as an event organizer.',
        );
      }
    } catch (error) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getUserProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();
    final data = document.data();

    if (!document.exists || data == null) {
      throw const AuthFailure(
        'No user profile was found for this account.',
      );
    }

    return data;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      throw const AuthFailure('Enter your email address first.');
    }

    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}