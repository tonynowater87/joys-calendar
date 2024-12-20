import 'dart:io';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/common/utils/dialog.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/common/button_style.dart';
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
    final analyticsHelper = context.read<AnalyticsHelper>();
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
                analyticsHelper.logEvent(name: event_backup_login, parameters: {
                  event_backup_login_params_type_name:
                      event_backup_login_params_type.google.toString(),
                });
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                analyticsHelper.logEvent(name: event_backup_login, parameters: {
                  event_backup_login_params_type_name:
                  event_backup_login_params_type.apple.toString(),
                });
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
                    child: Text('上次備份時間：$lastUpdatedTime')),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton.icon(
                      style: appOutlineButtonStyle(),
                      onPressed: () {
                        analyticsHelper.logEvent(name: event_backup_upload);
                        DialogUtils.showAlertDialog(
                            title: "上傳備份資料",
                            content: "注意：此動作會上傳覆蓋雲端資料\n請再次確認本地資料是否為想要備份的資料",
                            context: context,
                            onConfirmCallback: () async {
                              analyticsHelper.logEvent(
                                  name: event_backup_upload,
                                  parameters: {
                                    event_backup_upload_params_action_name:
                                        event_backup_upload_params_action
                                            .confirm
                                            .toString(),
                                  });
                              await loginCubit.upload();
                            },
                            onCancelCallback: () {
                              analyticsHelper.logEvent(
                                  name: event_backup_upload,
                                  parameters: {
                                    event_backup_upload_params_action_name:
                                        event_backup_upload_params_action.cancel
                                            .toString(),
                                  });
                            });
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('上傳'),
                    ),
                    OutlinedButton.icon(
                      style: appOutlineButtonStyle(),
                      onPressed: () {
                        analyticsHelper.logEvent(name: event_backup_download);
                        DialogUtils.showAlertDialog(
                            title: "下載還原資料",
                            content: "注意：此動作會將雲端資料覆蓋本地資料",
                            context: context,
                            onConfirmCallback: () async {
                              analyticsHelper.logEvent(
                                  name: event_backup_download,
                                  parameters: {
                                    event_backup_download_params_action_name:
                                        event_backup_download_params_action
                                            .confirm
                                            .toString(),
                                  });
                              await loginCubit.download();
                            },
                            onCancelCallback: () {
                              analyticsHelper.logEvent(
                                  name: event_backup_download,
                                  parameters: {
                                    event_backup_download_params_action_name:
                                        event_backup_download_params_action
                                            .cancel
                                            .toString(),
                                  });
                            });
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('下載'),
                    ),
                    OutlinedButton.icon(
                      style: appOutlineButtonStyle(),
                      onPressed: () {
                        analyticsHelper.logEvent(name: event_backup_delete);
                        DialogUtils.showAlertDialog(
                            title: "刪除帳號及雲端資料",
                            content: "注意：此動作會將帳號及雲端備份資料刪除，但不會影響手機內的資料",
                            context: context,
                            onConfirmCallback: () async {
                              analyticsHelper.logEvent(
                                  name: event_backup_delete,
                                  parameters: {
                                    event_backup_delete_params_action_name:
                                        event_backup_delete_params_action
                                            .confirm
                                            .toString(),
                                  });
                              await loginCubit.delete();
                            },
                            onCancelCallback: () {
                              analyticsHelper.logEvent(
                                  name: event_backup_delete,
                                  parameters: {
                                    event_backup_delete_params_action_name:
                                        event_backup_delete_params_action.cancel
                                            .toString(),
                                  });
                            });
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('刪除'),
                    ),
                    OutlinedButton.icon(
                      style: appOutlineButtonStyle(),
                      onPressed: () async {
                        analyticsHelper.logEvent(name: event_backup_logout);
                        await loginCubit.logout();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('登出'),
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
                      style: Theme.of(context).textTheme.bodyLarge)),
            ),
          ]);
      }
    }));
  }
}
