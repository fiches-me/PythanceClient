import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OnboardingPersonalInfoPage extends StatefulWidget {
  final Function(String, String, File?) onNext;

  const OnboardingPersonalInfoPage({super.key, required this.onNext});

  @override
  _OnboardingPersonalInfoPageState createState() => _OnboardingPersonalInfoPageState();
}

class _OnboardingPersonalInfoPageState extends State<OnboardingPersonalInfoPage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Info')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Step 2: About you', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? Icon(Icons.add_a_photo, size: 40) : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty) {
                  widget.onNext(_nameController.text, _lastNameController.text, _profileImage);
                }
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
