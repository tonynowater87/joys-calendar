import 'dart:io';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/common/utils/dialog.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/settings/login/login_cubit.dart';
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as AppleButton;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return LoginCubit(
          context.read<BackUpRepository>(), context.read<LocalDatasource>())
        ..init();
    }, child: BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
      final loginCubit = context.read<LoginCubit>();
      var fontSize = 20.0;
      switch (state.loginStatus) {
        case LoginStatus.notLogin:
          List<Widget> loginRows = [];
          Widget googleLoginButton = Container(
            height: 40,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: InkWell(
              onTap: () {
                loginCubit.login(LoginType.google);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: fontSize * (25 / 31),
                      height: fontSize,
                      child: Image.asset(
                        LoginType.google.getFileName(),
                        fit: BoxFit.cover,
                      )),
                  const SizedBox(
                    width: 6,
                  ),
                  Text('Google 登入',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontSize: fontSize, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );

          Widget appleLoginButton = SizedBox(
            width: 300,
            height: 40,
            child: AppleButton.AppleSignInButton(
              buttonText: 'Apple ID 登入',
              style: AppleButton.ButtonStyle.whiteOutline,
              onPressed: () {
                loginCubit.login(LoginType.appleId);
              },
            ),
          );

          if (Platform.isAndroid) {
            loginRows = [
              googleLoginButton,
              const SizedBox(
                height: 10,
              )
            ];
          } else if (Platform.isIOS) {
            loginRows = [
              appleLoginButton,
              const SizedBox(
                height: 10,
              ),
              googleLoginButton
            ];
          }

          loginRows.addAll([
            const SizedBox(
              height: 10,
            ),
            const Text('登入後可進行 備份／復原 我的記事')
          ]);

          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: loginRows,
              )
            ],
          );
        case LoginStatus.login:
          final fileSize = state.fileSize ?? "無";
          final localFileSize = state.localFileSize ?? "無";
          var dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
          String lastUpdatedTime;
          if (state.lastUpdatedTime == null) {
            lastUpdatedTime = "無";
          } else {
            lastUpdatedTime = dateFormat.format(state.lastUpdatedTime!);
          }
          final user = state.userId ?? "無";

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text(
                          "備份帳號：",
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                                state.loginType?.getFileName() ?? "",
                                fit: BoxFit.scaleDown),
                          ),
                        ),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(user),
                          ),
                        ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "雲端檔案大小：$fileSize",
                      textAlign: TextAlign.left,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "本地檔案大小：$localFileSize",
                      textAlign: TextAlign.left,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('上次更新時間：$lastUpdatedTime')),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: AnimatedButton(
                        width: 80,
                        height: 40,
                        color: AppColors.lightGreen,
                        onPressed: () {
                          DialogUtils.showAlertDialog(
                              title: "上傳備份資料",
                              content: "注意：此動作會上傳覆蓋雲端資料\n請再次確認本地資料是否為想要備份的資料",
                              context: context,
                              onConfirmCallback: () async {
                                await loginCubit.upload();
                              });
                        },
                        child: Text('上傳',
                            style: Theme.of(context).textTheme.bodyText1),
                      ),
                    ),
                    Center(
                      child: AnimatedButton(
                        width: 80,
                        height: 40,
                        color: AppColors.lightGreen,
                        onPressed: () {
                          DialogUtils.showAlertDialog(
                              title: "下載還原資料",
                              content: "注意：此動作會將雲端資料覆蓋本地資料",
                              context: context,
                              onConfirmCallback: () async {
                                await loginCubit.download();
                              });
                        },
                        child: Text('下載',
                            style: Theme.of(context).textTheme.bodyText1),
                      ),
                    ),
                    Center(
                      child: AnimatedButton(
                          width: 80,
                          height: 40,
                          color: AppColors.lightGreen,
                          onPressed: () async {
                            await loginCubit.logout();
                          },
                          child: Text('登出',
                              style: Theme.of(context).textTheme.bodyText1)),
                    ),
                    Center(
                      child: AnimatedButton(
                        width: 80,
                        height: 40,
                        color: AppColors.lightGreen,
                        onPressed: () {
                          DialogUtils.showAlertDialog(
                              title: "刪除雲端資料",
                              content: "注意：此動作會將雲端備份資料刪除，不會影響手機內的資料",
                              context: context,
                              onConfirmCallback: () async {
                                await loginCubit.delete();
                              });
                        },
                        child: Text('刪除',
                            style: Theme.of(context).textTheme.bodyText1),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        case LoginStatus.loading:
        case LoginStatus.deleting:
          var isLogin = state.userId != null;
          var isInit = state.localFileSize == null;
          var isDeleting = state.loginStatus == LoginStatus.deleting;
          String loadingText;

          if (isLogin) {
            if (isDeleting) {
              loadingText = '刪除雲端備份資料中...';
            } else if (isInit) {
              loadingText = '獲取雲端備份資訊中...';
            } else {
              loadingText = '處理中...';
            }
          } else {
            loadingText = '登入中...';
          }

          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(loadingText),
            const SizedBox(
              height: 10,
            ),
            const CircularProgressIndicator()
          ]);

        case LoginStatus.error:
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('錯誤：無法連接備份伺服器'),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: AnimatedButton(
                  width: 80,
                  height: 40,
                  color: AppColors.lightGreen,
                  onPressed: () async {
                    await loginCubit.init();
                  },
                  child: Text('重試一次',
                      style: Theme.of(context).textTheme.bodyText1)),
            ),
          ]);
      }
    }));
  }
}
