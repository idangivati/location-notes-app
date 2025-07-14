import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import 'note_list_screen.dart';
import 'note_map_screen.dart';
import 'note_screen.dart';
import 'home/widgets/app_bar_widget.dart';
import 'home/widgets/bottom_navi_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    NoteListScreen(),
    NoteMapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notesState = ref.watch(notesProvider);
    final userEmail = authState.user?.email ?? 'User';
    final firstName = userEmail.split('@').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(
        firstName: firstName,
        notesCount: notesState.notes.length,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NoteScreen()),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, size: 28, color: Colors.white),
    );
  }
}