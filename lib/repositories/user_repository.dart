import 'package:hive/hive.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class UserRepository {
  late final Box<User> _userBox;
  late final Box _settingsBox;

  UserRepository() {
    _userBox = StorageService.userBox;
    _settingsBox = StorageService.settingsBox;
  }

  // User management
  Future<void> saveUser(User user) async {
    await _userBox.put('current_user', user);
  }

  User? getCurrentUser() {
    return _userBox.get('current_user');
  }

  Future<void> updateUser(User user) async {
    await _userBox.put('current_user', user);
  }

  Future<void> deleteUser() async {
    await _userBox.delete('current_user');
  }

  // Settings management
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Filter period preference
  Future<void> saveFilterPeriod(FilterPeriod period) async {
    await _settingsBox.put('filter_period', period.index);
  }

  FilterPeriod getFilterPeriod() {
    final index = _settingsBox.get('filter_period', defaultValue: 0) as int;
    return FilterPeriod.values[index];
  }

  // Base currency preference
  Future<void> saveBaseCurrency(String currency) async {
    await _settingsBox.put('base_currency', currency);
  }

  String getBaseCurrency() {
    return _settingsBox.get('base_currency', defaultValue: 'USD') as String;
  }

  // Theme preference
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _settingsBox.put('is_dark_mode', isDarkMode);
  }

  bool getThemeMode() {
    return _settingsBox.get('is_dark_mode', defaultValue: false) as bool;
  }

  // Onboarding completion
  Future<void> markOnboardingComplete() async {
    await _settingsBox.put('onboarding_complete', true);
  }

  bool isOnboardingComplete() {
    return _settingsBox.get('onboarding_complete', defaultValue: false) as bool;
  }

  // Create default user for demo purposes
  Future<User> createDefaultUser() async {
    final now = DateTime.now();
    final user = User(
      id: 'default_user',
      name: 'Shihab Rahman',
      email: 'shihab@example.com',
      baseCurrency: 'USD',
      createdAt: now,
      updatedAt: now,
    );
    
    await saveUser(user);
    return user;
  }
}
