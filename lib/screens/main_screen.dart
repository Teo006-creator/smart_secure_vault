import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'vault_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    VaultListScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationController>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: nav.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        ),
        child: BottomNavigationBar(
          currentIndex: nav.selectedIndex,
          onTap: (index) => nav.setIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.cardColor,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.lock_rounded), label: 'Bóveda'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alertas'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}
