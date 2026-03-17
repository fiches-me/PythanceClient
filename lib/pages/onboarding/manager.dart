import 'package:flutter/material.dart';
import '../../requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'infos.dart';
import 'tools.dart';
import 'org.dart';
import '../../navigation.dart';
import '../../config.dart';

class OnboardingFlowManager extends StatefulWidget {
  const OnboardingFlowManager({super.key});

  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlowManager> {
  final PageController _pageController = PageController();
  String? _name, _lastName;
  File? _profileImage;
  List<Map<String, dynamic>>? _tools;
  String? _groupCode;

  Future<void> _submitOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    try {
      final url = '${Config.apiBaseUrl}/auth/onboard/';
      final data = await postWithHeaders(url, {
        'email': email,
        'group_code': _groupCode,
        'first_name': _name,
        'last_name': _lastName,
        'tools': _tools,
      });

      // Assuming success will return a map with success:true
      if (data is Map<String, dynamic> && (data['success'] == true)) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationBarPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to complete onboarding')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          OnboardingGroupPage(onNext: (groupCode) {
            setState(() => _groupCode = groupCode);
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
          }),
          OnboardingPersonalInfoPage(onNext: (name, lastName, image) {
            setState(() {
              _name = name;
              _lastName = lastName;
              _profileImage = image;
            });
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
          }),
          OnboardingToolsPage(onNext: (tools) {
            setState(() => _tools = tools);
            _submitOnboarding();
          }),
        ],
      ),
    );
  }
}
