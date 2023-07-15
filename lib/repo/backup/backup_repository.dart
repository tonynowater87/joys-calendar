import 'package:firebase_auth/firebase_auth.dart';

enum LoginType {
  google,
  appleId, //TODO
  anonymous; //TODO
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
