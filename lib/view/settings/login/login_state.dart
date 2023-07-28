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
  String? userId; // email or apple id
  String? fileSize;
  String? localFileSize;
  DateTime? lastUpdatedTime;
  LoginType? loginType;
  LoginStatus loginStatus;

  LoginState(
      {this.userId,
      this.fileSize,
      this.localFileSize,
      this.lastUpdatedTime,
      this.loginType,
      required this.loginStatus});

  LoginState copyWith({required LoginStatus loginStatus}) {
    return LoginState(
      userId: userId,
      fileSize: fileSize,
      localFileSize: localFileSize,
      lastUpdatedTime: lastUpdatedTime,
      loginType: loginType,
      loginStatus: loginStatus,
    );
  }

  @override
  List<Object?> get props =>
      [userId, fileSize, localFileSize, lastUpdatedTime, loginType, loginStatus];
}
