import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:joys_calendar/common/constants.dart';
import 'package:joys_calendar/common/utils/file.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  BackUpRepository backupRepository;
  LocalDatasource localDatasource;
  String? _adUnitId;
  InterstitialAd? _interstitialAd;

  LoginCubit(this.backupRepository, this.localDatasource)
      : super(backupRepository.isLogin()
            ? LoginState(
                userId: backupRepository.getUser()?.email,
                fileSize: null,
                localFileSize: null,
                lastUpdatedTime: null,
                loginType: backupRepository.getLoginType(),
                loginStatus: LoginStatus.login)
            : LoginState(loginStatus: LoginStatus.notLogin)) {
    if (Platform.isAndroid) {
      _adUnitId = AppConstants.INTERSTITIAL_ANDROID_ID;
    } else if (Platform.isIOS) {
      _adUnitId = AppConstants.INTERSTITIAL_IOS_ID;
    }
  }

  Future<void> init() async {
    _loadInterstitialAd();
    if (backupRepository.isLogin()) {
      final localFileSize =
          await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
      emit(state.copyWith(loginStatus: LoginStatus.loading));
      final fetchState = await backupRepository.fetch();
      debugPrint('[Tony] init, state=$fetchState');
      if (fetchState == BackUpStatus.notChanged) {
        emit(LoginState(
            localFileSize: localFileSize,
            userId: backupRepository.getUser()?.email,
            loginType: backupRepository.getLoginType(),
            loginStatus: LoginStatus.login));
        return;
      }
      if (fetchState == BackUpStatus.fail) {
        emit(LoginState(
            userId: backupRepository.getUser()?.email,
            fileSize: null,
            localFileSize: null,
            lastUpdatedTime: null,
            loginType: backupRepository.getLoginType(),
            loginStatus: LoginStatus.error));
        return;
      }
      emit(LoginState(
          userId: backupRepository.getUser()?.email,
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
        userId: backupRepository.getUser()?.email,
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
      emit(LoginState(
          userId: state.userId,
          localFileSize: state.localFileSize,
          fileSize: state.localFileSize,
          loginType: state.loginType,
          lastUpdatedTime: backupRepository.getLastUpdatedTime(),
          loginStatus: LoginStatus.login));
      return;
    }

    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    _showAd();
    Fluttertoast.showToast(msg: "上傳備份資料成功！");
    emit(LoginState(
        loginStatus: LoginStatus.login,
        userId: backupRepository.getUser()?.email,
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
      emit(LoginState(
          userId: state.userId,
          localFileSize: state.localFileSize,
          fileSize: state.localFileSize,
          loginType: state.loginType,
          lastUpdatedTime: backupRepository.getLastUpdatedTime(),
          loginStatus: LoginStatus.login));
      return;
    }

    final localFileSize =
        await FileUtils.calculateFileSize(localDatasource.localMemoToJson());
    _showAd();
    Fluttertoast.showToast(msg: "下載還原資料成功！");
    emit(LoginState(
        loginStatus: LoginStatus.login,
        userId: backupRepository.getUser()?.email,
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
        Fluttertoast.showToast(msg: "成功刪除帳號及雲端備份資料！");
        emit(LoginState(loginStatus: LoginStatus.notLogin));
        break;
      case BackUpStatus.fail:
        emit(state.copyWith(loginStatus: LoginStatus.login));
        Fluttertoast.showToast(msg: "刪除帳號及雲端備份資料失敗，請再重試一次！");
        break;
      case BackUpStatus.cancel:
      case BackUpStatus.notChanged:
        emit(LoginState(
            localFileSize: state.localFileSize,
            userId: backupRepository.getUser()?.email,
            loginType: backupRepository.getLoginType(),
            loginStatus: LoginStatus.login));
        break;
    }
  }

  void _showAd() async {
    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
  }

  Future<void> _loadInterstitialAd() async {
    if (_adUnitId == null) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    await InterstitialAd.load(
      adUnitId: _adUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          stopwatch.stop();
          final duration = stopwatch.elapsedMilliseconds;
          debugPrint('[Tony] onAdLoaded, duration=$duration');
          // almost 1~2 seconds
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          _interstitialAd?.dispose();
          _interstitialAd = null;
          // stopwatch.reset();
          debugPrint('[Tony] onAdFailedToLoad, err=$err');
        },
      ),
    );
  }
}
