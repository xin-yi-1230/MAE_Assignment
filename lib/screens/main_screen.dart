import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'event/event_list_screen.dart';
import 'rating/rating_screen.dart';
import 'order/order_history_screen.dart'; 
import 'notices/notices_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // All screens live here simultaneously
  // IndexedStack keeps them all alive in memory
  // only shows the active one
  final List<Widget> _screens = const [
    DashboardScreen(),
    EventListScreen(),
    OrderHistoryScreen(),
    NoticesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack shows only the selected screen
      // but keeps ALL screens alive in memory
      // so state is preserved when switching tabs
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
