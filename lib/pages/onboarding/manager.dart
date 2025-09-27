import 'package:flutter/material.dart';
import 'dart:io';

import 'start.dart';
import 'infos.dart';
import 'tools.dart';
import 'org.dart';

class OnboardingFlowManager extends StatefulWidget {
  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();

}
class _OnboardingFlowState extends State<OnboardingFlowManager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _name, _lastName;
  File? _profileImage;
  List<Map<String, dynamic>>? _tools;
  String? _groupCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          OnboardingWelcomePage(onGetStarted: () => _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease)),
          OnboardingPersonalInfoPage(onNext: (name, lastName, image) {
            setState(() {
              _name = name;
              _lastName = lastName;
              _profileImage = image;
            });
            _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          OnboardingToolsPage(onNext: (tools) {
            setState(() {
              _tools = tools;
            });
            _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          OnboardingGroupPage(onFinish: (groupCode) {
            setState(() {
              _groupCode = groupCode;
            });
            // Send all data to your API here
            print('Name: $_name, Last Name: $_lastName, Tools: $_tools, Group: $_groupCode');
            // Navigate to home
          }),
        ],
      ),
    );
  }
}
