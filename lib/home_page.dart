import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/app_top_nav_bar.dart';
import 'task_manager_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Home is the center

  static const List<String> _titles = [
    'Tarefas',
    'Flashcards',
    'Home',
    'Assistente',
    'Bibliotecas',
  ];

  late final List<Widget> _pages = [
    TaskManagerPage(isDarkMode: widget.isDarkMode),
    const Center(child: Text('Flashcards')),
    const Center(child: Text('Home')),
    const Center(child: Text('Assistente')),
    const Center(child: Text('Bibliotecas')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopNavBar(
        title: _titles[_selectedIndex],
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


