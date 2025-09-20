import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserInitial()) {
    
    on<LoadUser>(_onLoadUser);
    on<LoginUser>(_onLoginUser);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<SignUpUser>(_onSignUpUser);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LogoutUser>(_onLogoutUser);
    on<CreateDefaultUser>(_onCreateDefaultUser);
  }

  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      final user = _userRepository.getCurrentUser();
      
      if (user != null) {
        emit(UserAuthenticated(user));
      } else {
        emit(const UserUnauthenticated());
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to load user',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoginUser(
    LoginUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserActionLoading('login'));

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any valid email/password combination
      if (_isValidEmail(event.email) && event.password.length >= 6) {
        final now = DateTime.now();
        final user = User(
          id: 'demo_user_${now.millisecondsSinceEpoch}',
          name: _extractNameFromEmail(event.email),
          email: event.email,
          baseCurrency: 'USD',
          createdAt: now,
          updatedAt: now,
        );

        await _userRepository.saveUser(user);
        await _userRepository.markOnboardingComplete();

        emit(UserActionSuccess(
          action: 'login',
          message: 'Login successful',
          user: user,
        ));

        emit(UserAuthenticated(user));
      } else {
        emit(const UserError(
          message: 'Invalid credentials',
          details: 'Please check your email and password',
        ));
      }
    } catch (e) {
      emit(UserError(
        message: 'Login failed',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserActionLoading('google_login'));

      // Simulate Google authentication
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      final user = User(
        id: 'google_user_${now.millisecondsSinceEpoch}',
        name: 'Shihab Rahman',
        email: 'shihab@gmail.com',
        baseCurrency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      await _userRepository.saveUser(user);
      await _userRepository.markOnboardingComplete();

      emit(UserActionSuccess(
        action: 'google_login',
        message: 'Google login successful',
        user: user,
      ));

      emit(UserAuthenticated(user));
    } catch (e) {
      emit(UserError(
        message: 'Google login failed',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onSignUpUser(
    SignUpUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserActionLoading('signup'));

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Basic validation
      if (!_isValidEmail(event.email)) {
        emit(const UserError(
          message: 'Invalid email format',
        ));
        return;
      }

      if (event.password.length < 6) {
        emit(const UserError(
          message: 'Password must be at least 6 characters',
        ));
        return;
      }

      if (event.name.trim().isEmpty) {
        emit(const UserError(
          message: 'Name is required',
        ));
        return;
      }

      final now = DateTime.now();
      final user = User(
        id: 'user_${now.millisecondsSinceEpoch}',
        name: event.name.trim(),
        email: event.email.toLowerCase(),
        baseCurrency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      await _userRepository.saveUser(user);
      await _userRepository.markOnboardingComplete();

      emit(UserActionSuccess(
        action: 'signup',
        message: 'Account created successfully',
        user: user,
      ));

      emit(UserAuthenticated(user));
    } catch (e) {
      emit(UserError(
        message: 'Sign up failed',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserActionLoading('update'));

      final updatedUser = event.user.copyWith(
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(updatedUser);

      emit(UserActionSuccess(
        action: 'update',
        message: 'Profile updated successfully',
        user: updatedUser,
      ));

      emit(UserAuthenticated(updatedUser));
    } catch (e) {
      emit(UserError(
        message: 'Failed to update profile',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserActionLoading('logout'));

      await _userRepository.deleteUser();

      emit(const UserActionSuccess(
        action: 'logout',
        message: 'Logged out successfully',
      ));

      emit(const UserUnauthenticated());
    } catch (e) {
      emit(UserError(
        message: 'Logout failed',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onCreateDefaultUser(
    CreateDefaultUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      final user = await _userRepository.createDefaultUser();
      await _userRepository.markOnboardingComplete();

      emit(UserAuthenticated(user));
    } catch (e) {
      emit(UserError(
        message: 'Failed to create default user',
        details: e.toString(),
      ));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      final name = parts[0];
      // Capitalize first letter and replace dots/underscores with spaces
      return name
          .replaceAll(RegExp(r'[._]'), ' ')
          .split(' ')
          .map((word) => word.isNotEmpty 
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word)
          .join(' ');
    }
    return 'User';
  }
}
