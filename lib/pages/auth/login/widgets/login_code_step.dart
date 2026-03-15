import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginCodeStep extends StatelessWidget {
  final String email;
  final List<TextEditingController> codeControllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onCodeCompleted;

  const LoginCodeStep({
    super.key,
    required this.email,
    required this.codeControllers,
    required this.focusNodes,
    required this.onCodeCompleted,
  });

  bool get _codeFull => codeControllers.every((c) => c.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verification', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Entrez le code envoye a $email',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: codeControllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                  }
                  if (_codeFull) {
                    onCodeCompleted();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

