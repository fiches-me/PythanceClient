import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../navigation.dart';
import '../onboarding/manager.dart';
import '../../config.dart';
import 'login/login_step.dart';
import 'login/widgets/login_bottom_button.dart';
import 'login/widgets/login_code_step.dart';
import 'login/widgets/login_email_step.dart';
import 'login/widgets/login_welcome_step.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  LoginStep _step = LoginStep.welcome;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/login/'),
        body: json.encode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            _step = LoginStep.code;
            _errorMessage = null;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            FocusScope.of(context).requestFocus(_focusNodes[0]);
          });
        } else {
          if (!mounted) return;
          setState(() => _errorMessage = data['message']);
        }
      } else {
        if (!mounted) return;
        setState(() => _errorMessage = 'Erreur serveur. Veuillez réessayer.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur de connexion.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_isLoading) {
      return;
    }

    final email = _emailController.text.trim();
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Entrez le code à 6 chiffres');
      return;
    }

    setState(() => _isLoading = true);
    try {
      log('Verifying code: $code');
      log('Email: $email');
      log('API URL: ${Config.apiBaseUrl}/auth/verify/');
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/verify/'),
        body: json.encode({'email': email, 'code': code}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('api_key', data['key']);
          if (!mounted) return;
          if (data['newuser'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingFlowManager(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationBarPage()),
            );
          }
        } else {
          if (!mounted) return;
          setState(() => _errorMessage = data['message']);
        }
      } else {
        if (!mounted) return;
        setState(() => _errorMessage = 'Code incorrect.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur de connexion.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Hero(
                    tag: 'logo',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SvgPicture.asset(
                        'assets/icon/logo.svg',
                        height: 56,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onPrimaryContainer,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildStepContent(),
                  ),
                  const Spacer(),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w500)),
                    ),
                  _buildBottomAction(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case LoginStep.welcome:
        return const LoginWelcomeStep();
      case LoginStep.email:
        return LoginEmailStep(emailController: _emailController);
      case LoginStep.code:
        return LoginCodeStep(
          email: _emailController.text,
          codeControllers: _codeControllers,
          focusNodes: _focusNodes,
          onCodeCompleted: _verifyCode,
        );
    }
  }

  Widget _buildBottomAction() {
    String text = "";
    VoidCallback? onPressed;

    if (_step == LoginStep.welcome) {
      text = "Commencer";
      onPressed = () {
        setState(() {
          _errorMessage = null;
          _step = LoginStep.email;
        });
      };
    } else if (_step == LoginStep.email) {
      text = "Continuer";
      onPressed = _sendEmail;
    } else if (_step == LoginStep.code) {
      text = "Vérifier";
      onPressed = _verifyCode;
    }

    return LoginBottomButton(
      text: text,
      isLoading: _isLoading,
      onPressed: onPressed,
    );
  }
}
