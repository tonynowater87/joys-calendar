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
            ? LoginState(
                user: backupRepository.getUser(),
                fileSize: null,
                localFileSize: null,
                lastUpdatedTime: null,
                loginType: backupRepository.getLoginType(),
                loginStatus: LoginStatus.login)
            : LoginState(loginStatus: LoginStatus.notLogin));

  Future<void> init() async {
    if (backupRepository.isLogin()) {
      final localFileSize =
          await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
      emit(state.copyWith(loginStatus: LoginStatus.loading));
      final fetchState = await backupRepository.fetch();
      debugPrint('[Tony] init, state=$fetchState');
      if (fetchState == BackUpStatus.notChanged) {
        emit(LoginState(
            localFileSize: localFileSize,
            user: backupRepository.getUser(),
            loginType: backupRepository.getLoginType(),
            loginStatus: LoginStatus.login));
        return;
      }
      if (fetchState == BackUpStatus.fail) {
        emit(LoginState(
            user: backupRepository.getUser(),
            fileSize: null,
            localFileSize: null,
            lastUpdatedTime: null,
            loginType: backupRepository.getLoginType(),
            loginStatus: LoginStatus.error));
        return;
      }
      emit(LoginState(
          user: backupRepository.getUser(),
          fileSize: backupRepository.getFileSize(),
          localFileSize: localFileSize,
          lastUpdatedTime: backupRepository.getLastUpdatedTime(),
          loginType: backupRepository.getLoginType(),
          loginStatus: LoginStatus.login));
    }
  }

  Future<void> login(LoginType loginType) async {
    emit(LoginState(loginStatus: LoginStatus.loading));
    BackUpStatus? loginStatus;
    loginStatus = await backupRepository.login(loginType);

    if (loginStatus == BackUpStatus.fail) {
      await backupRepository.logout();
      Fluttertoast.showToast(msg: "登入發生異常！");
      emit(LoginState(loginStatus: LoginStatus.notLogin));
      return;
    }

    if (loginStatus == BackUpStatus.cancel) {
      await backupRepository.logout();
      emit(LoginState(loginStatus: LoginStatus.notLogin));
      return;
    }

    loginStatus = await backupRepository.fetch();

    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    emit(LoginState(
        loginStatus: LoginStatus.login,
        user: backupRepository.getUser(),
        fileSize: backupRepository.getFileSize(),
        localFileSize: localFileSize,
        lastUpdatedTime: backupRepository.getLastUpdatedTime(),
        loginType: backupRepository.getLoginType()));
  }

  Future<void> logout() async {
    await backupRepository.logout();
    Fluttertoast.showToast(msg: "登出成功！");
    emit(LoginState(loginStatus: LoginStatus.notLogin));
  }

  Future<void> upload() async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));
    final status = await backupRepository.upload();
    if (status == BackUpStatus.fail) {
      Fluttertoast.showToast(msg: "上傳備份資料失敗！");
      emit(state.copyWith(loginStatus: LoginStatus.login));
      return;
    }

    if (status == BackUpStatus.notChanged) {
      Fluttertoast.showToast(msg: "資料沒有異動！");
      emit(state.copyWith(loginStatus: LoginStatus.login));
      return;
    }

    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    Fluttertoast.showToast(msg: "上傳備份資料成功！");
    emit(LoginState(
        loginStatus: LoginStatus.login,
        user: backupRepository.getUser(),
        fileSize: backupRepository.getFileSize(),
        localFileSize: localFileSize,
        lastUpdatedTime: backupRepository.getLastUpdatedTime(),
        loginType: backupRepository.getLoginType()));
  }

  Future<void> download() async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));
    final status = await backupRepository.download();
    if (status == BackUpStatus.fail) {
      Fluttertoast.showToast(msg: "下載還原資料失敗！");
      emit(state.copyWith(loginStatus: LoginStatus.login));
      return;
    }

    if (status == BackUpStatus.notChanged) {
      Fluttertoast.showToast(msg: "資料沒有異動！");
      emit(state.copyWith(loginStatus: LoginStatus.login));
      return;
    }

    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    Fluttertoast.showToast(msg: "下載還原資料成功！");
    emit(LoginState(
        loginStatus: LoginStatus.login,
        user: backupRepository.getUser(),
        fileSize: backupRepository.getFileSize(),
        localFileSize: localFileSize,
        lastUpdatedTime: backupRepository.getLastUpdatedTime(),
        loginType: backupRepository.getLoginType()));
  }

  Future<void> delete() async {
    emit(state.copyWith(loginStatus: LoginStatus.deleting));
    var result = await backupRepository.delete();
    switch (result) {
      case BackUpStatus.success:
        Fluttertoast.showToast(msg: "成功刪除雲端備份資料！");
        emit(LoginState(
            user: backupRepository.getUser(),
            loginStatus: LoginStatus.login,
            loginType: backupRepository.getLoginType(),
            localFileSize: state.localFileSize));
        break;
      case BackUpStatus.notChanged:
      case BackUpStatus.cancel:
      case BackUpStatus.fail:
        emit(state.copyWith(loginStatus: LoginStatus.login));
        Fluttertoast.showToast(msg: "刪除雲端資料失敗，請再重試一次！");
        break;
    }
  }
}
