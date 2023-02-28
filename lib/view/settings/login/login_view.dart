import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/common/utils/dialog.dart';
import 'package:joys_calendar/repo/backup/backup_repository.dart';
import 'package:joys_calendar/repo/local/local_datasource.dart';
import 'package:joys_calendar/view/settings/login/login_cubit.dart';

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
    }, child: BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final loginCubit = context.read<LoginCubit>();
        if (state is NotLogin) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide()))),
                  onPressed: () {
                    loginCubit.login();
                  },
                  child: const Text('登入')),
              const Text('即可備份／復原記錄'),
            ],
          );
        } else if (state is Login) {
          final fileSize = state.fileSize ?? "無";
          final localFileSize = state.localFileSize ?? "無";
          var dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
          String lastUpdatedTime;
          if (state.lastUpdatedTime == null) {
            lastUpdatedTime = "無";
          } else {
            lastUpdatedTime = dateFormat.format(state.lastUpdatedTime!);
          }
          final user = state.user?.email ?? "無";
          final loginType = state.loginType;
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
                        Visibility(
                          visible: loginType == LoginType.google,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.network(
                                'http://pngimg.com/uploads/google/google_PNG19635.png',
                                fit: BoxFit.cover),
                          ),
                        ),
                        Text(user),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "檔案大小：$fileSize(雲端)\t $localFileSize(本地)",
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
                          child: const Text('上傳')),
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
                          child: const Text('下載')),
                    ),
                    Center(
                      child: AnimatedButton(
                          width: 80,
                          height: 40,
                          color: AppColors.lightGreen,
                          onPressed: () async {
                            await loginCubit.logout();
                          },
                          child: const Text('登出')),
                    )
                  ],
                ),
              )
            ],
          );
        } else {
          throw Exception("not expected state=$state");
        }
      },
    ));
  }
}
