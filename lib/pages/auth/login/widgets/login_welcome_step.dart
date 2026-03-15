import 'package:flutter/material.dart';

class LoginWelcomeStep extends StatelessWidget {
  const LoginWelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pythance', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 12),
        Text(
          'Cuisinez ensemble, gerez vos ustensiles et planifiez vos repas en toute simplicite.',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

