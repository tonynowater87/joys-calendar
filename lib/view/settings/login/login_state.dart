part of 'login_cubit.dart';

@immutable
abstract class LoginState extends Equatable {}

class NotLogin extends LoginState {

  bool isLoading;

  NotLogin({this.isLoading = false});

  @override
  List<Object?> get props => [isLoading];
}

class Login extends LoginState {
  User? user;
  String? fileSize;
  String? localFileSize;
  DateTime? lastUpdatedTime;
  LoginType? loginType;
  bool isLoading;

  Login({this.user,
    this.fileSize,
    this.localFileSize,
    this.lastUpdatedTime,
    this.loginType,
    this.isLoading = false});

  Login copyWith(bool isLoading) {
    return Login(
        user: user,
        fileSize: fileSize,
        localFileSize: fileSize,
        lastUpdatedTime: lastUpdatedTime,
        loginType: loginType,
        isLoading: isLoading
    );
  }

  @override
  List<Object?> get props =>
      [user, fileSize, localFileSize, lastUpdatedTime, loginType, isLoading];
}
