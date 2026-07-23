import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_assignment/screens/auth/login_page.dart';
import 'package:flutter_application_assignment/screens/main_screen.dart';
import 'package:flutter_application_assignment/viewmodels/booth_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/cart_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/event_detail_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/event_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/notice_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/order_viewmodel.dart';
import 'package:flutter_application_assignment/viewmodels/review_viewmodel.dart';
import 'package:provider/provider.dart';

import '../home/role_home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authenticationSnapshot) {
        if (authenticationSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPage();
        }

        final user = authenticationSnapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        return RoleRouter(user: user);
      },
    );
  }
}

class RoleRouter extends StatelessWidget {
  const RoleRouter({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPage();
        }

        if (profileSnapshot.hasError) {
          return AccountProblemPage(
            message: 'Unable to load the account profile.',
          );
        }

        final document = profileSnapshot.data;
        final profile = document?.data();

        if (document == null || !document.exists || profile == null) {
          return const AccountProblemPage(
            message: 'The user profile does not exist in Firestore.',
          );
        }

        final role = profile['role'] as String?;
        final name = profile['name'] as String? ?? 'User';
        final isActive = profile['isActive'] as bool? ?? true;

        if (!isActive) {
          return const AccountProblemPage(
            message: 'This account has been disabled.',
          );
        }

        switch (role) {
          case 'organizer':
            return RoleHomePage(
              title: 'Organizer Dashboard',
              accountName: name,
              role: 'Event Organizer',
              icon: Icons.admin_panel_settings,
            );

          case 'boothOwner':
            return RoleHomePage(
              title: 'Booth Owner Dashboard',
              accountName: name,
              role: 'Booth Owner',
              icon: Icons.store,
            );

          case 'operationStaff':
            return RoleHomePage(
              title: 'Operation Staff Dashboard',
              accountName: name,
              role: 'Operation Staff',
              icon: Icons.engineering,
            );

          case 'visitor':
            // ── Wrap MainScreen with all providers ──
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => DashboardViewModel()),
                ChangeNotifierProvider(create: (_) => EventViewModel()),
                ChangeNotifierProvider(create: (_) => EventDetailViewModel()),
                ChangeNotifierProvider(create: (_) => BoothViewModel()),
                ChangeNotifierProvider(create: (_) => CartViewModel()),
                ChangeNotifierProvider(create: (_) => OrderViewModel()),
                ChangeNotifierProvider(create: (_) => ReviewViewModel()),
                ChangeNotifierProvider(create: (_) => NoticeViewModel()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                home: const MainScreen(),
              ),
            );

          default:
            return const AccountProblemPage(
              message: 'This account has an invalid role.',
            );
        }
      },
    );
  }
}

class AccountProblemPage extends StatelessWidget {
  const AccountProblemPage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
