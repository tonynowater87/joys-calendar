import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:joys_calendar/common/extentions/NumberExtentions.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseBackUpRepository implements BackUpRepository {
  static const String backupFileName = "memo.json";

  final googleSignIn = GoogleSignIn(scopes: ['email']);
  LocalDatasource localDatasource;
  FirebaseAuth firebaseAuth;
  FirebaseStorage firebaseStorage;
  SharedPreferenceProvider sharedPreferenceProvider;

  LoginType? loginType;
  User? currentUser;
  DateTime? lastUpdatedTime;
  String? fileSize;

  FirebaseBackUpRepository(
      {required this.localDatasource,
      required this.firebaseAuth,
      required this.firebaseStorage,
      required this.sharedPreferenceProvider}) {
    currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      loginType = LoginType.google;
    }
    var hasRunBefore = sharedPreferenceProvider.getHasRunBefore();
    debugPrint(
        '[Tony] FirebaseBackUpRepository init, currentUser=$currentUser');
    debugPrint(
        '[Tony] FirebaseBackUpRepository init, hasRunBefore=$hasRunBefore');
    if (!hasRunBefore) {
      try {
        logout();
      } on Exception catch (e) {}
    }
    sharedPreferenceProvider.setHasRunBefore(true);
  }

  @override
  Future<BackUpStatus> fetch() async {
    try {
      if (currentUser == null) {
        /// user does not login
        return BackUpStatus.fail;
      }
      final selfFile = firebaseStorage.refFromURL(
          "gs://joy-calendar-358617.appspot.com/${currentUser!.uid}");

      final metaData = await selfFile.getMetadata();
      _readMetaDataField(metaData);
      debugPrint('[Tony] lastUpdatedTime=$lastUpdatedTime, fileSize=$fileSize');
      return BackUpStatus.success;
    } on Exception catch (e) {
      return BackUpStatus.fail;
    }
  }

  @override
  Future<BackUpStatus> login(LoginType loginType) async {
    try {
      switch (loginType) {
        case LoginType.google:
          final signOutUser = await googleSignIn.signOut();
          debugPrint(
              '[Tony] signOut success, user=${signOutUser?.displayName}');
          final user = await googleSignIn.signIn();

          if (user == null) {
            debugPrint('[Tony] login cancel, $user');
            return BackUpStatus.cancel;
          }

          // Obtain the auth details from the request
          final GoogleSignInAuthentication googleAuth =
              await user.authentication;
          // Create a new credential
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          // Once signed in, return the UserCredential
          currentUser =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;
          break;
        case LoginType.anonymous:
          currentUser = (await firebaseAuth.signInAnonymously()).user;
          break;
      }
      debugPrint('[Tony] login success, user=${currentUser?.uid}');
      this.loginType = loginType;
      return BackUpStatus.success;
    } on Exception catch (e) {
      debugPrint('[Tony] login failure, e=$e');
      return BackUpStatus.fail;
    }
  }

  @override
  Future<BackUpStatus> logout() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
    currentUser = null;
    fileSize = null;
    lastUpdatedTime = null;
    loginType = null;
    return BackUpStatus.success;
  }

  @override
  Future<BackUpStatus> upload() async {
    try {
      // db to json
      String json = localDatasource.localMemoToJson();
      if (json.isEmpty) {
        debugPrint('[Tony] 上傳, 本地無資料');
        return BackUpStatus.notChanged;
      }

      final reference = firebaseStorage.ref();
      final allRefs = await reference.listAll();
      var uuid = currentUser!.uid;
      var existData =
          allRefs.items.where((element) => element.name == uuid).toList();
      debugPrint('[Tony] 上傳, currentUser=$uuid');
      Reference dataRef;
      if (existData.isNotEmpty) {
        debugPrint('[Tony] 上傳, 目前帳號在雲端有資料');
        dataRef = existData.first;
      } else {
        debugPrint('[Tony] 上傳, 目前帳號在雲端沒資料');
        dataRef = reference.child(uuid);
      }

      // json to local file
      var appDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDir.path}/$backupFileName";
      File file = File(filePath);
      await file.writeAsString(json, flush: true);

      try {
        FullMetadata? fullMetadata = await dataRef.getMetadata();

        debugPrint(
            '[Tony] 上傳, remote customMetadata=${fullMetadata.customMetadata}');

        if (fullMetadata.customMetadata != null) {
          String? previousHash = fullMetadata.customMetadata!['hash'];
          debugPrint('[Tony] 上傳, previousHash=$previousHash');

          if (json.hashCode.toString() == previousHash) {
            debugPrint('[Tony] 上傳, 資料未異動');
            return BackUpStatus.notChanged;
          }
        }
      } on FirebaseException catch (e) {
        debugPrint("[Tony] 沒上傳過檔案=$e");
      }
      final metaData =
          SettableMetadata(customMetadata: {'hash': json.hashCode.toString()});

      // upload json to firestorage
      await dataRef.putFile(file);
      final updatedMetaData = await dataRef.updateMetadata(metaData);
      _readMetaDataField(updatedMetaData);
      debugPrint('[Tony] 上傳成功, $uuid');
      return BackUpStatus.success;
    } on FirebaseException catch (e) {
      debugPrint("[Tony] 上傳失敗，FirebaseException=$e");
      return BackUpStatus.fail;
    } on Exception catch (e) {
      debugPrint("[Tony] 上傳失敗，Exception=$e");
      return BackUpStatus.fail;
    }
  }

  @override
  Future<BackUpStatus> download({String? token}) async {
    final uuid = currentUser?.uid ?? token!;
    final reference = FirebaseStorage.instance.ref();
    final dataRef = reference.child(uuid);

    String jsonNow = localDatasource.localMemoToJson();
    FullMetadata fullMetadata;
    try {
      fullMetadata = await dataRef.getMetadata();
      if (fullMetadata.customMetadata != null) {
        String? previousHash = fullMetadata.customMetadata!['hash'];
        if (jsonNow.hashCode.toString() == previousHash) {
          debugPrint('[Tony] 下載, 資料沒有異動');
          return BackUpStatus.notChanged;
        }
      }
    } on FirebaseException catch (e) {
      debugPrint('[Tony] 下載, 找不到檔案=$e');
      return BackUpStatus.fail;
    }

    // file to json
    var appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/$backupFileName";
    File file = File(filePath);
    await dataRef.writeToFile(file);
    final json = await file.readAsString();
    debugPrint('[Tony] 下載, 成功, uid=$uuid, download=$json');
    await localDatasource.replaceWithJson(json);
    _readMetaDataField(fullMetadata);
    return BackUpStatus.success;
  }

  void _readMetaDataField(FullMetadata metaData) {
    lastUpdatedTime = metaData.updated;
    fileSize = metaData.size!.bytesToFileSizeString();
  }

  @override
  bool isLogin() {
    return currentUser != null;
  }

  @override
  String? getFileSize() {
    return fileSize;
  }

  @override
  DateTime? getLastUpdatedTime() {
    return lastUpdatedTime;
  }

  @override
  User? getUser() {
    return firebaseAuth.currentUser;
  }

  @override
  LoginType? getLoginType() {
    return loginType;
  }
}
