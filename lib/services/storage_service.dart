import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/models/TodoModel.dart';

class StorageService {
  static const String _currentUserKey = 'current_user';
  static const String _todosPrefix = 'todos_';

  // Save current user email
  static Future<void> saveCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, email);
  }

  // Get current user email
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Clear current user (logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Save todos for a specific user
  static Future<void> saveTodos(String email, List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = todos.map((todo) => todo.toJson()).toList();
    final jsonString = jsonEncode(todoListJson);
    await prefs.setString('$_todosPrefix$email', jsonString);
  }

  // Load todos for a specific user
  static Future<List<Todo>> loadTodos(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_todosPrefix$email');

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  // Check if user exists (has todos saved)
  static Future<bool> userExists(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_todosPrefix$email');
  }
}