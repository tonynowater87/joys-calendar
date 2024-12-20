import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/common/utils/dialog.dart';
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
                context
                    .read<AnalyticsHelper>()
                    .logEvent(name: event_setting_notify, parameters: {
                  event_setting_notify_country_holiday_name: checked.toString()
                });
                debugPrint('[Tony] onChanged: $checked');
                context.read<SettingsNotifyCubit>().setCalendarNotify(checked);
              }),
          SwitchListTile(
              title: const Text('農曆２４節氣'),
              activeColor: Colors.green,
              value: state.solarNotify,
              onChanged: (checked) {
                context.read<AnalyticsHelper>().logEvent(
                    name: event_setting_notify,
                    parameters: {
                      event_setting_notify_solar_name: checked.toString()
                    });
                debugPrint('[Tony] onChanged: $checked');
                context.read<SettingsNotifyCubit>().setSolarNotify(checked);
              }),
          SwitchListTile(
              title: const Text('我的記事'),
              activeColor: Colors.green,
              value: state.memoNotify,
              onChanged: (checked) {
                context.read<AnalyticsHelper>().logEvent(
                    name: event_setting_notify,
                    parameters: {
                      event_setting_notify_memo_name: checked.toString()
                    });
                debugPrint('[Tony] onChanged: $checked');
                context.read<SettingsNotifyCubit>().setMemoNotify(checked);
              }),
          ListTile(
            title: const Text('通知時間'),
            subtitle: Row(
              children: [
                const Icon(Icons.info_outline, size: 10),
                const SizedBox(width: 4),
                Text('固定前一天提醒, 可自訂通知時間',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            trailing: InkWell(
              onTap: () async {
                var time = await showTimePicker(
                    context: context,
                    initialTime: state.notifyTime,
                    helpText: '選擇通知時間');

                if (!context.mounted) {
                  return;
                }
                if (time != null) {
                  context.read<SettingsNotifyCubit>().setNotifyTime(time);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(state.notifyTime.format(context)),
                  const SizedBox(width: 4),
                  const Icon(Icons.access_time)
                ],
              ),
            ),
          ),
        ],
      );
    }, listener: (BuildContext context, state) {
      debugPrint('[Tony] notify listener: $state');
      if (state.isLoading) {
        DialogUtils.showLoaderDialog(context, "更新通知提醒...");
      } else {
        var isDialogShowing = DialogUtils.isDialogShowing(context);
        debugPrint('[Tony] notify isDialogShowing: $isDialogShowing');
        if (isDialogShowing) {
          Navigator.of(context).pop();
        }
      }

      if (state.showNotifyAlertPermissionDialog) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('通知權限'),
                content: const Text('請至設定開啟通知權限'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        NotificationPermissions.requestNotificationPermissions(
                            openSettings: true);
                      },
                      child: const Text('確定'))
                ],
              );
            });
      }
    });
  }
}
