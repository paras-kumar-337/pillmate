import 'package:flutter/material.dart';
import 'Signup.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            "Log In",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 110),

          const LoginForm(),
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

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging in...')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  0,
                  115,
                  255,
                ).withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Log In', style: TextStyle(fontSize: 18),),
            ),
          ),
          SizedBox(height: 110),
          Center(
            child: Text('Not a member?', style: TextStyle(color: Colors.white, fontSize: 16))
          ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
                    onPressed:  () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[400]!.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    ),
                    child: Text('Sign Up'),
                  ),
          ),
        ],
      ),
    );
  }
}
