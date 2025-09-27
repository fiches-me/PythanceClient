import 'package:flutter/material.dart';

class OnboardingGroupPage extends StatefulWidget {
  final Function(String?) onFinish;

  OnboardingGroupPage({required this.onFinish});

  @override
  _OnboardingGroupPageState createState() => _OnboardingGroupPageState();
}

class _OnboardingGroupPageState extends State<OnboardingGroupPage> {
  final _groupCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join a Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupCodeController,
              decoration: InputDecoration(labelText: 'Group Code (optional)'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => widget.onFinish(_groupCodeController.text.isEmpty ? null : _groupCodeController.text),
                  child: Text('Finish'),
                ),
                TextButton(
                  onPressed: () => widget.onFinish(null),
                  child: Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
