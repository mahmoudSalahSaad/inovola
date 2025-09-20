import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/user.dart';

class StorageService {
  static const String _expenseBoxName = 'expenses';
  static const String _userBoxName = 'user';
  static const String _settingsBoxName = 'settings';

  static Box<Expense>? _expenseBox;
  static Box<User>? _userBox;
  static Box? _settingsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
    Hive.registerAdapter(UserAdapter());

    // Open boxes
    _expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
    _userBox = await Hive.openBox<User>(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Box<Expense> get expenseBox {
    if (_expenseBox == null || !_expenseBox!.isOpen) {
      throw Exception('Expense box is not initialized or closed');
    }
    return _expenseBox!;
  }

  static Box<User> get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('User box is not initialized or closed');
    }
    return _userBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not initialized or closed');
    }
    return _settingsBox!;
  }

  static Future<void> close() async {
    await _expenseBox?.close();
    await _userBox?.close();
    await _settingsBox?.close();
  }

  static Future<void> clearAllData() async {
    await _expenseBox?.clear();
    await _userBox?.clear();
    await _settingsBox?.clear();
  }
}
