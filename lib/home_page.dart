import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/app_top_nav_bar.dart';
import 'profile_page.dart';
import 'task_manager_page.dart';
import 'flashcard_page.dart';
import 'assistant_page.dart';
import 'library_page.dart';

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
    FlashcardPage(
      isDarkMode: widget.isDarkMode,
      onThemeToggle: widget.onThemeToggle,
    ),
    const Center(child: Text('Home')),
    AssistantPage(
      isDarkMode: widget.isDarkMode,
      onThemeToggle: widget.onThemeToggle,
    ),
    LibraryPage(
      isDarkMode: widget.isDarkMode,
      onThemeToggle: widget.onThemeToggle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopNavBar(
        title: _titles[_selectedIndex],
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        onProfileTap: _openProfile,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
