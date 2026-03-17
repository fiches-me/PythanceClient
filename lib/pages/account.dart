import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _code(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          SizedBox(height: 20),
          Text(
            'Mon Compte',
            style: TextStyle(fontFamily: 'Unbounded', fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            'Quoi écrire ? Bonne question...',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _code(context),
            icon: Icon(Icons.local_activity),
            label: Text('Code Secret'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.inversePrimary,
              foregroundColor: colorScheme.primary,
            ),

          ),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout),
            label: Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.error,
            ),

          )
        ],
      ),
    );
  }
}
