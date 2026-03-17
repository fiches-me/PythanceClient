import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart';
import 'pages/account.dart';
import 'pages/tools_usage.dart';
import 'pages/add_plate.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  _NavigationBarPageState createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _currentIndex = 0;

  String? _gravatarUrl;

  final List<Widget> _pages = [
    const HomePage(),
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
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlatePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
