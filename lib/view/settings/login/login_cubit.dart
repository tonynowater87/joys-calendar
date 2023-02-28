import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:joys_calendar/common/utils/file.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  BackUpRepository backupRepository;
  LocalDatasource localDatasource;

  LoginCubit(this.backupRepository, this.localDatasource)
      : super(backupRepository.isLogin()
            ? Login(
                user: backupRepository.getUser(),
                fileSize: backupRepository.getFileSize(),
                localFileSize: null,
                lastUpdatedTime: backupRepository.getLastUpdatedTime(),
                loginType: backupRepository.getLoginType())
            : NotLogin());

  Future<void> init() async {
    if (backupRepository.isLogin()) {
      final localFileSize =
          await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
      print('[Tony] init, localFileSize=$localFileSize');
      emit(Login(
          user: backupRepository.getUser(),
          fileSize: backupRepository.getFileSize(),
          localFileSize: localFileSize,
          lastUpdatedTime: backupRepository.getLastUpdatedTime(),
          loginType: backupRepository.getLoginType()));
    }
  }

  Future<void> login() async {
    var loginStatus = await backupRepository.login(LoginType.google);
    await backupRepository.fetch();
    if (loginStatus == BackUpStatus.fail) {
      await backupRepository.logout();
      Fluttertoast.showToast(msg: "登入發生異常！");
      return Future.value();
    }
    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    emit(Login(
        user: backupRepository.getUser(),
        fileSize: backupRepository.getFileSize(),
        localFileSize: localFileSize,
        lastUpdatedTime: backupRepository.getLastUpdatedTime(),
        loginType: backupRepository.getLoginType()));
  }

  Future<void> logout() async {
    await backupRepository.logout();
    Fluttertoast.showToast(msg: "登出成功！");
    emit(NotLogin());
  }

  Future<void> upload() async {
    final status = await backupRepository.upload();
    if (status == BackUpStatus.fail) {
      Fluttertoast.showToast(msg: "上傳備份資料失敗！");
      return Future.value();
    }
    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    Fluttertoast.showToast(msg: "上傳備份資料成功！");
    emit(Login(
        user: backupRepository.getUser(),
        fileSize: backupRepository.getFileSize(),
        localFileSize: localFileSize,
        lastUpdatedTime: backupRepository.getLastUpdatedTime(),
        loginType: backupRepository.getLoginType()));
  }

  Future<void> download() async {
    final status = await backupRepository.download();
    if (status == BackUpStatus.fail) {
      Fluttertoast.showToast(msg: "下載還原資料失敗！");
      return Future.value();
    }
    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    Fluttertoast.showToast(msg: "下載還原資料成功！");
    emit(Login(
        user: backupRepository.getUser(),
        fileSize: backupRepository.getFileSize(),
        localFileSize: localFileSize,
        lastUpdatedTime: backupRepository.getLastUpdatedTime(),
        loginType: backupRepository.getLoginType()));
  }
}