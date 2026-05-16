import 'package:flutter/material.dart';

import '../widgets/glass_bottom_navigation.dart';
import 'dashboard_screen.dart';
import 'help_screen.dart';
import 'photos_screen.dart';
import 'program_screen.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    const DashboardScreen(),
    const ProgramScreen(),
    const RoomScreen(),
    const PhotosScreen(),
    const HelpScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: GlassBottomNavigation(
        selectedIndex: selectedIndex,
        onChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
