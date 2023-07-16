import 'package:firebase_auth/firebase_auth.dart';

enum LoginType {
  google,
  appleId, //TODO
  anonymous; //TODO
}

extension LoginTypeExtension on LoginType {
  String getFileName() {
    switch (this) {
      case LoginType.google:
        return 'assets/icons/google-login.png';
      case LoginType.appleId:
        return 'assets/icons/apple-login.png';
      case LoginType.anonymous:
        return '';
      default:
        throw ArgumentError('Unknown enum value: $this');
    }
  }
}

enum BackUpStatus { success, notChanged, fail, cancel }

class LoginModel {
  LoginType loginType;
  String token;

  LoginModel(this.loginType, this.token);
}

abstract class BackUpRepository {
  bool isLogin();

  LoginType? getLoginType();

  User? getUser();

  String? getFileSize();

  DateTime? getLastUpdatedTime();

  Future<BackUpStatus> login(LoginType loginType);

  Future<BackUpStatus> fetch();

  Future<BackUpStatus> logout();

  Future<BackUpStatus> upload();

  Future<BackUpStatus> download({String? token});
}
