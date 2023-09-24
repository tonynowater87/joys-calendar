import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/settings/notify/settings_notify_cubit.dart';
import 'package:notification_permissions/notification_permissions.dart';

class SettingsNotifyPage extends StatelessWidget {
  const SettingsNotifyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsNotifyCubit, SettingsNotifyState>(
        builder: (BuildContext context, state) {
          return Column(
            children: [
              SwitchListTile(
                  title: const Text('國家節日'),
                  activeColor: Colors.green,
                  value: state.calendarNotify,
                  onChanged: (checked) {
                    debugPrint('[Tony] onChanged: $checked');
                    context
                        .read<SettingsNotifyCubit>()
                        .setCalendarNotify(checked);
                  }),
              SwitchListTile(
                  title: const Text('農曆２４節氣'),
                  activeColor: Colors.green,
                  value: state.solarNotify,
                  onChanged: (checked) {
                    debugPrint('[Tony] onChanged: $checked');
                    context.read<SettingsNotifyCubit>().setSolarNotify(checked);
                  }),
              SwitchListTile(
                  title: const Text('我的記事'),
                  activeColor: Colors.green,
                  value: state.memoNotify,
                  onChanged: (checked) {
                    debugPrint('[Tony] onChanged: $checked');
                    context.read<SettingsNotifyCubit>().setMemoNotify(checked);
                  }),
              ListTile(
                dense: true,
                title: Row(
                  children: const [
                    Icon(Icons.info_outlined),
                    SizedBox(width: 8),
                    Text('通知提醒的時間為前1日的早上9點'),
                  ],
                ),
              ),
            ],
          );
        },
        listener: (BuildContext context, state) =>
        state.showNotifyAlertPermissionDialog
            ? showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: const Text('未允許通知權限'),
                  content: const Text('請至手機設定開啟通知權限'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          NotificationPermissions
                              .requestNotificationPermissions(
                              openSettings: true);
                          Navigator.of(context).pop();
                        },
                        child: const Text('前往'))
                  ],
                ))
            : null);
  }
}
