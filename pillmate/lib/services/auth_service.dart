import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class AuthService {
  final DBHelper _dbHelper = DBHelper();

  Future<bool> signup(String name, String email, String password, String question, String answer) async {
    try {
      await _dbHelper.insertUser(name, email, password, question, answer);
      return true;
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final user = await _dbHelper.getUser(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", user["name"]);
      await prefs.setString("user_email", user["email"]);
      return true;
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("user_email");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> updateProfile(String email, String newName, String newPassword) async {
    try {
      await _dbHelper.updateUser(
        email,
        newName,
        newPassword.isEmpty ? null : newPassword,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", newName);

      return true;
    } catch (e) {
      print("Update Profile Error: $e");
      return false;
    }
  }

  Future<String?> getSecurityQuestion(String email) async {
    final user = await _dbHelper.getUserByEmail(email);
    return user?['security_question'] as String?;
  }

  Future<bool> resetPassword(String email, String answer, String newPassword) async {
    final user = await _dbHelper.getUserByEmail(email);

    if (user == null) {
      return false;
    }

    final String storedAnswer = user['security_answer'] as String? ?? '';

    if (storedAnswer == answer.trim().toLowerCase()) {
      await _dbHelper.resetPassword(email, newPassword);
      return true;
    }

    return false;
  }
}