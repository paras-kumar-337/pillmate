import 'package:flutter/material.dart';
import 'Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'Login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();


  // Controllers for dynamic data
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController medicalHistoryController;

  String _userName = "User";
  String _userEmail = "Loading...";

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    medicalHistoryController = TextEditingController();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString("user_name") ?? "User";
      _userEmail = prefs.getString("user_email") ?? "No Email";

      nameController.text = _userName;
      emailController.text = _userEmail;
    });
  }

  Future<void> _logout() async {
    await _auth.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged Out!"),
        backgroundColor: Colors.blueGrey, // You can use any color
      ),
    );

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  Future<void> _handleUpdate() async {
    if (emailController.text != _userEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email cannot be changed."),
          backgroundColor: Colors.red,
        ),
      );
      emailController.text = _userEmail;
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final newName = nameController.text.trim();
    final newPassword = passwordController.text.trim();

    bool success = await _auth.updateProfile(
      _userEmail,
      newName,
      newPassword,
    );

    setState(() {
      _isUpdating = false;
    });

    if (success){
      setState(() {
        _userName = newName;
      });

      passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updated Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Update Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text(
                    "Welcome, ",
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  Text(
                    "$_userName!",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Name", style: _labelStyle),
              _inputField(nameController),
              const SizedBox(height: 20),
              const Text("Email (Cannot be changed)", style: _labelStyle),
              _inputField(emailController),
              const SizedBox(height: 20),
              const Text("New Password", style: _labelStyle),
              _inputField(passwordController, isPassword: true),
              const SizedBox(height: 20),
              const Text("Medical History", style: _labelStyle),
              _largeInputField(medicalHistoryController),
              const SizedBox(height: 30),
              _updateButton(),
              const SizedBox(height: 25),
              _logoutButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  Widget _inputField(
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => controller.clear(),
        ),
      ),
    );
  }

  Widget _largeInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Add your medical details here",
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
      ),
    );
  }

  Widget _updateButton() {
    return ElevatedButton(
      onPressed: _isUpdating ? null : _handleUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: _isUpdating ?
      const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ) 
      : const Text("Update"),
    );
  }

  Widget _logoutButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 184, 12, 0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text("Log Out"),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.medication_liquid,
            label: "Medicines",
            active: false,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const DashboardScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          _navItem(
            icon: Icons.person,
            label: "Profile",
            active: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF007AFF) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF007AFF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
