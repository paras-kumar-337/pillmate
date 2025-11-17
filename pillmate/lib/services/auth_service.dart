import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class AuthService {
  final DBHelper _dbHelper = DBHelper();

  Future<bool> signup(String name, String email, String password) async {
    try {
      await _dbHelper.insertUser(name, email, password);
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
}