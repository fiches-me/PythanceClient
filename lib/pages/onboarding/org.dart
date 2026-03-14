import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class OnboardingGroupPage extends StatefulWidget {
  final Function(String?) onNext;

  const OnboardingGroupPage({super.key, required this.onNext});

  @override
  _OnboardingGroupPageState createState() => _OnboardingGroupPageState();
}

class _OnboardingGroupPageState extends State<OnboardingGroupPage> {
  final _groupCodeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _checkAndProceed() async {
    final code = _groupCodeController.text.trim();
    if (code.isEmpty) {
      widget.onNext(null);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/verify-group'),
        body: json.encode({'group_code': code}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true || data['valid'] == true) {
          widget.onNext(code);
        } else {
          setState(() => _errorMessage = 'Invalid group code.');
        }
      } else {
        setState(() => _errorMessage = 'Failed to verify group.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Group')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Step 1: Join your group', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextField(
              controller: _groupCodeController,
              decoration: const InputDecoration(labelText: 'Group Code', border: OutlineInputBorder()),
            ),
            if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _checkAndProceed, child: const Text('Next')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
