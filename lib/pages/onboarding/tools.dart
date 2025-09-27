import 'package:flutter/material.dart';

class OnboardingToolsPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onNext;

  OnboardingToolsPage({required this.onNext});

  @override
  _OnboardingToolsPageState createState() => _OnboardingToolsPageState();
}

class _OnboardingToolsPageState extends State<OnboardingToolsPage> {
  final List<Map<String, dynamic>> _selectedTools = [];
  String? _selectedToolType;
  final Map<String, int> _toolTypeIds = {
    'Casserole': 1,
    'Poêle': 2,
    'Cookeo': 3,
    // Add more as needed
  };

  void _addTool() {
    if (_selectedToolType != null) {
      setState(() {
        _selectedTools.add({
          'name': _selectedToolType!,
          'type_id': _toolTypeIds[_selectedToolType!]!,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedToolType,
              hint: Text('Select a tool'),
              items: _toolTypeIds.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedToolType = newValue;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTool,
              child: Text('Add Tool'),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: _selectedTools.map((tool) => Chip(label: Text(tool['name']))).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => widget.onNext(_selectedTools),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
