import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  const LoadUser();
}

class LoginUser extends UserEvent {
  final String email;
  final String password;

  const LoginUser({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogle extends UserEvent {
  const LoginWithGoogle();
}

class SignUpUser extends UserEvent {
  final String name;
  final String email;
  final String password;

  const SignUpUser({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class UpdateUserProfile extends UserEvent {
  final User user;

  const UpdateUserProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class LogoutUser extends UserEvent {
  const LogoutUser();
}

class CreateDefaultUser extends UserEvent {
  const CreateDefaultUser();
}
