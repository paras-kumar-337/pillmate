import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF88DBFF), Color.fromARGB(255, 30, 154, 255)],
            radius: 0.75,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 60),
                    const ResetPasswordStepper(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordStepper extends StatefulWidget {
  const ResetPasswordStepper({super.key});

  @override
  State<ResetPasswordStepper> createState() => _ResetPasswordStepperState();
}

class _ResetPasswordStepperState extends State<ResetPasswordStepper> {
  final AuthService _auth = AuthService();

  int _currentStep = 0;
  bool _isLoading = false;

  final _emailKey = GlobalKey<FormState>();
  final _answerKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _securityQuestion = '';
  bool _isPasswordObscured = true;

  Future<void> _findUser() async {
    if (!_emailKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final question = await _auth.getSecurityQuestion(_emailController.text.trim());
    setState(() => _isLoading = false);

    if (question != null) {
      setState(() {
        _securityQuestion = question;
        _currentStep = 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user found with this email.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verifyAnswer() {
    if (!_answerKey.currentState!.validate()) return;

    setState(() => _currentStep = 2);
  }

  Future<void> _resetPassword() async {
    if (!_passwordKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _auth.resetPassword(
      _emailController.text.trim(),
      _answerController.text.trim(),
      _newPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password has been reset! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security answer is incorrect. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _currentStep = 1);
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: _emailKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Email',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => v!.contains('@') && v.contains(".")
                    ? null
                    : 'Please enter a valid email',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _findUser,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Next'),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Security Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: _answerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _securityQuestion,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              TextFormField(
                controller: _answerController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter your answer' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyAnswer,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('New Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: _passwordKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isPasswordObscured,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => v!.length >= 8 ? null : 'Password must be at least 8 characters',
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isPasswordObscured,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => v!.isEmpty ? 'Please confirm your password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 0, 155, 65),
          secondary: Colors.white,
        ),
        canvasColor: Colors.transparent,
      ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        controlsBuilder: (context, details) {
          return Container(); 
        },
        steps: _buildSteps(),
      ),
    );
  }
}