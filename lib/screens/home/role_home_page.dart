import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RoleHomePage extends StatelessWidget {
  const RoleHomePage({
    required this.title,
    required this.accountName,
    required this.role,
    required this.icon,
    super.key,
  });

  final String title;
  final String accountName;
  final String role;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, $accountName',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Authentication and role routing are working.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}