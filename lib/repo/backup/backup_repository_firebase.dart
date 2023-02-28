import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:joys_calendar/common/extentions/NumberExtentions.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:path_provider/path_provider.dart';

// TODO indicate progress with upload and download
class FirebaseBackUpRepository implements BackUpRepository {
  static const String backupFileName = "memo.json";

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
    print('[Tony] currentUser=$currentUser');
    print('[Tony] hasRunBefore=$hasRunBefore');
    if (!hasRunBefore) {
      try {
        logout();
      } on Exception catch (e) {}
    } else {
      if (currentUser != null) {
        fetch();
      }
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
      print('[Tony] lastUpdatedTime=$lastUpdatedTime, fileSize=$fileSize');
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
          final googleSignIn = GoogleSignIn(scopes: ['email']);
          final user = await googleSignIn.signIn();
          // Obtain the auth details from the request
          final GoogleSignInAuthentication? googleAuth =
          await user?.authentication;
          // Create a new credential
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
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
      print('[Tony] login success, user=${currentUser?.uid}');
      this.loginType = loginType;
      return BackUpStatus.success;
    } on Exception catch(e) {
      return BackUpStatus.fail;
    }
  }

  @override
  Future<BackUpStatus> logout() async {
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
      final reference = firebaseStorage.ref();
      final allRefs = await reference.listAll();
      var uuid = currentUser!.uid;
      var existData =
          allRefs.items.where((element) => element.name == uuid).toList();
      print('[Tony] currentUser=$uuid');
      Reference dataRef;
      if (existData.isNotEmpty) {
        print('[Tony] existData');
        dataRef = existData.first;
      } else {
        print('[Tony] newData');
        dataRef = reference.child(uuid);
      }

      // db to json
      String json = localDatasource.localMemoToJson();
      if (json.isEmpty) {
        print('[Tony] no data');
        return BackUpStatus.notChanged;
      }

      // json to local file
      var appDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDir.path}/$backupFileName";
      File file = File(filePath);
      await file.writeAsString(json, flush: true);

      try {
        FullMetadata fullMetadata = await dataRef.getMetadata();

        if (fullMetadata.customMetadata != null) {
          String previousHash = fullMetadata.customMetadata!['hash']!;
          if (json.hashCode.toString() == previousHash) {
            print('[Tony] not change, upload return');
            return BackUpStatus.notChanged;
          }
        }
      } on FirebaseException catch (e) {
        print("[Tony] 沒上傳過檔案=$e");
      }
      final metaData =
          SettableMetadata(customMetadata: {'hash': json.hashCode.toString()});

      // upload json to firestorage
      await dataRef.putFile(file);
      final updatedMetaData = await dataRef.updateMetadata(metaData);
      _readMetaDataField(updatedMetaData);
      print('[Tony] 上傳成功, ${uuid}');
      return BackUpStatus.success;
    } on FirebaseException catch (e) {
      print("[Tony] 上傳失敗，FirebaseException=$e");
      return BackUpStatus.fail;
    } on Exception catch (e) {
      print("[Tony] 上傳失敗，Exception=$e");
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
        String previousHash = fullMetadata.customMetadata!['hash']!;
        if (jsonNow.hashCode.toString() == previousHash) {
          print('[Tony] not change, download return');
          return BackUpStatus.notChanged;
        }
      }
    } on FirebaseException catch (e) {
      print('[Tony] 找不到檔案=$e');
      return BackUpStatus.fail;
    }

    // file to json
    var appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/$backupFileName";
    File file = File(filePath);
    await dataRef.writeToFile(file);
    final json = await file.readAsString();
    print('[Tony] uid=$uuid, download=$json');
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