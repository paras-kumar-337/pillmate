import 'package:flutter/material.dart';
import 'Login.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
  decoration: const BoxDecoration(
    gradient: RadialGradient(
      colors: [
        Color(0xFF88DBFF),
        Color.fromARGB(255, 30, 154, 255),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: AssetImage('assets/logo.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 60),

          const SignupForm(),
        ],
      ),
    ),
  ),
),
    )
      )
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formkey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  String? _selectedQuestion;
  final List<String> _securityQuestions = [
    'What is your mother\'s name?',
    'What was the name of your first pet?',
    'What is your city of birth?',
  ];

  bool _isObscured = true;
  bool loading = false;

  void _signUp() async {
    if (_selectedQuestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a security question."),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    setState(() => loading = true);

    bool success = await _auth.signup(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      _selectedQuestion!,
      answerController.text.trim(),
    );

    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign up successful! Please log in."),
          backgroundColor: Colors.green,
        )
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign up failed! Email already exists."),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Name",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextFormField(
            controller: nameController,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v!.isEmpty ? "Please enter a valid name" : null,
          ),
          const SizedBox(height: 20),
          const Text(
            "Email",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v!.contains("@") && v.contains(".") ? null : "Please enter a valid email",
          ),
          const SizedBox(height: 20),
          const Text(
            "Password",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextFormField(
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _isObscured,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v!.length >= 8 ? null : "Password must be at least 8 characters",
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Security Question",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedQuestion,
              items: _securityQuestions.map((String question) {
                return DropdownMenuItem<String>(
                  value: question,
                  child: Text(question, style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedQuestion = newValue;
                });
              },
              hint: const Text("Select a question", style: TextStyle(color: Colors.black54)),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              validator: (v) => v == null ? 'Please select a question' : null,
            ),
          ),
          
          const SizedBox(height: 20),
          const Text(
            "Your Answer",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextFormField(
            controller: answerController,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v!.isEmpty ? "Please answer your question" : null,
            decoration: const InputDecoration(
              hintText: "Your answer (e.g., 'Dell' or 'Buddy')",
              hintStyle: TextStyle(color: Colors.white54)
            ),
          ),

          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: loading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 155, 65).withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: loading ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ) : const Text('Sign Up', style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 60),
          Center(
            child: Text('Already a member?', style: TextStyle(color: Colors.white, fontSize: 16))
          ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
                    onPressed:  () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 227, 227, 227),
                      foregroundColor: Color.fromARGB(255, 0, 0, 0),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    ),
                    child: Text('Log In'),
                  ),
          ),
        ],
      ),
    );
  }
}