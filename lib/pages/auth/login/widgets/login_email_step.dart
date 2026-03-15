import 'package:flutter/material.dart';

class LoginEmailStep extends StatelessWidget {
  final TextEditingController emailController;

  const LoginEmailStep({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Votre email', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Nous vous enverrons un code de connexion magique.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: emailController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'nom@exemple.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

