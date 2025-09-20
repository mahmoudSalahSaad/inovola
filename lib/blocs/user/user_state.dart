import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserAuthenticated extends UserState {
  final User user;

  const UserAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
}

class UserError extends UserState {
  final String message;
  final String? details;

  const UserError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

class UserActionLoading extends UserState {
  final String action; // 'login', 'signup', 'update', 'logout'

  const UserActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}

class UserActionSuccess extends UserState {
  final String action;
  final String message;
  final User? user;

  const UserActionSuccess({
    required this.action,
    required this.message,
    this.user,
  });

  @override
  List<Object?> get props => [action, message, user];
}
