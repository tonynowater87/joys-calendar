part of 'login_cubit.dart';

@immutable
abstract class LoginState extends Equatable {}

class NotLogin extends LoginState {
  @override
  List<Object?> get props => [];
}

class Login extends LoginState {
  User? user;
  String? fileSize;
  String? localFileSize;
  DateTime? lastUpdatedTime;
  LoginType? loginType;

  Login({
    this.user,
    this.fileSize,
    this.localFileSize,
    this.lastUpdatedTime,
    this.loginType
  });

  @override
  List<Object?> get props => [user, fileSize, localFileSize, lastUpdatedTime, loginType];
}
