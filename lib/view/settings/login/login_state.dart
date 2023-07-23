part of 'login_cubit.dart';

enum LoginStatus {
  notLogin,
  login,
  loading,
  deleting,
  error,
}

@immutable
class LoginState extends Equatable {
  User? user;
  String? fileSize;
  String? localFileSize;
  DateTime? lastUpdatedTime;
  LoginType? loginType;
  LoginStatus loginStatus;

  LoginState(
      {this.user,
      this.fileSize,
      this.localFileSize,
      this.lastUpdatedTime,
      this.loginType,
      required this.loginStatus});

  LoginState copyWith({required LoginStatus loginStatus}) {
    return LoginState(
      user: user,
      fileSize: fileSize,
      localFileSize: localFileSize,
      lastUpdatedTime: lastUpdatedTime,
      loginType: loginType,
      loginStatus: loginStatus,
    );
  }

  @override
  List<Object?> get props =>
      [user, fileSize, localFileSize, lastUpdatedTime, loginType, loginStatus];
}
