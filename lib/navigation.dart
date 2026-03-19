import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart';
import 'pages/account.dart';
import 'pages/tools_usage.dart';
import 'pages/search.dart';
import 'pages/add_plate.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  _NavigationBarPageState createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _currentIndex = 0;

  // Track the last tapped destination index in the NavigationBar (0..n-1).
  // We keep this separate from _currentIndex because the middle destination
  // (index 2) is used to open the Add page and is not one of the pages in
  // `_pages`.
  int _lastSelectedDestination = 0;

  String? _gravatarUrl;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ToolsUsagePage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadGravatar();
  }

  Future<void> _loadGravatar() async {
    final prefs = await SharedPreferences.getInstance();
    // utiliser une valeur par défaut vide si l'email n'est pas défini
    final email = prefs.getString('email') ?? '';
    // Construire l'URL Gravatar même si l'email est vide (package gère cela)
    try {
      final url = Gravatar(email).imageUrl();
      setState(() {
        _gravatarUrl = url;
      });
    } catch (e) {
      // En cas d'erreur, laisser _gravatarUrl à null pour afficher le fallback
      setState(() {
        _gravatarUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construire l'icône du compte : si on a une URL Gravatar, afficher l'image
    Widget _buildAccountIcon({bool selected = false}) {
      final double size = selected ? 28 : 24;
      if (_gravatarUrl != null && _gravatarUrl!.isNotEmpty) {
        log('URL Gravatar : $_gravatarUrl');
        return ClipOval(
          child: Image.network(
            _gravatarUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            // fallback si l'image ne peut pas être chargée
            errorBuilder: (context, error, stackTrace) => Icon(
              selected ? Icons.person : Icons.person_outlined,
              size: size,
            ),
          ),
        );
      }
      return Icon(selected ? Icons.person : Icons.person_outlined);
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        // Use the last tapped destination index for visual selection. The
        // logical page index (_currentIndex) maps to destinations as follows:
        // dest 0 -> page 0, dest 1 -> page 1, dest 2 -> ADD (not a page),
        // dest 3 -> page 2 (if you had a separate page), dest 4 -> page 2
        selectedIndex: _lastSelectedDestination,
        onDestinationSelected: (index) {
          // If the center destination (index 2) is tapped, open the Add page
          // without changing the selected content page.
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPlatePage()),
            );
            return;
          }

          setState(() {
            // remember which destination was tapped so the UI highlights it
            _lastSelectedDestination = index;

            // Map destination indices to page indices. Because destination
            // list contains an extra center action at index 2 we shift the
            // indices after it by -1 to match our `_pages` array.
            if (index < 2) {
              _currentIndex = index;
            } else {
              _currentIndex = index - 1;
            }
          });
        },
        // destinations ne peuvent pas être const car elles utilisent des valeurs runtime
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search_outlined),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            selectedIcon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: 'Ajouter',
          ),
          const NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Ustensiles',
          ),
          NavigationDestination(
            icon: _buildAccountIcon(selected: false),
            selectedIcon: _buildAccountIcon(selected: true),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}
