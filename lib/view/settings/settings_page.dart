import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/common/utils/notification_helper.dart';
import 'package:joys_calendar/repo/app_info_provider.dart';
import 'package:joys_calendar/repo/calendar_event_repositoy.dart';
import 'package:joys_calendar/repo/local_notification_provider.dart';
import 'package:joys_calendar/repo/shared_preference_provider.dart';
import 'package:joys_calendar/view/settings/event/settings_calendar_bloc.dart';
import 'package:joys_calendar/view/settings/event/settings_calendar_grid_list_view.dart';
import 'package:joys_calendar/view/settings/login/login_view.dart';
import 'package:joys_calendar/view/settings/notify/settings_notify_cubit.dart';
import 'package:joys_calendar/view/settings/notify/settings_notify_page.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<SettingsTitleItem> settingsItem = [
    SettingsTitleItem(SettingType.eventType, true),
    SettingsTitleItem(SettingType.notify, true),
    SettingsTitleItem(SettingType.backup, true),
    // SettingsTitleItem(SettingType.locale, false) // TODO future feature
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  ExpansionPanelList(
                      expansionCallback: (index, bool) {
                        setState(() {
                          settingsItem[index].isExpanded = !bool;
                        });
                      },
                      children: settingsItem.map<ExpansionPanel>((item) {
                        switch (item.headerValue) {
                          case SettingType.eventType:
                            return ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder: (context, bool isExpanded) {
                                  return ListTile(
                                      title: Text(
                                    item.headerValue.toLocalization(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ));
                                },
                                body: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: BlocProvider(
                                    create: (context) => SettingsCalendarBloc(
                                        context.read<CalendarEventRepository>(),
                                        context
                                            .read<SharedPreferenceProvider>(),
                                        context
                                            .read<LocalNotificationProvider>(),
                                        context.read<NotificationHelper>()),
                                    child: const SettingsCalendarGridListView(),
                                  ),
                                ),
                                isExpanded: !item.isExpanded);
                          case SettingType.locale:
                            return ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder: (context, bool isExpanded) {
                                  return ListTile(
                                      title: Text(
                                    item.headerValue.toLocalization(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ));
                                },
                                body: const ListTile(title: Text('施工中...')),
                                isExpanded: !item.isExpanded);
                          case SettingType.backup:
                            return ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder: (context, bool isExpanded) {
                                  return ListTile(
                                      title: Text(
                                    item.headerValue.toLocalization(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ));
                                },
                                body: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 200,
                                    width: 400,
                                    child: LoginView(),
                                  ),
                                ),
                                isExpanded: !item.isExpanded);
                          case SettingType.notify:
                            return ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder: (context, bool isExpanded) {
                                  return ListTile(
                                      title: Text(
                                    item.headerValue.toLocalization(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ));
                                },
                                body: BlocProvider(
                                  create: (context) => SettingsNotifyCubit(
                                      localNotificationProvider: context
                                          .read<LocalNotificationProvider>(),
                                      sharedPreferenceProvider: context
                                          .read<SharedPreferenceProvider>(),
                                      calendarEventRepository: context
                                          .read<CalendarEventRepository>(),
                                      notificationHelper:
                                          context.read<NotificationHelper>()),
                                  child: const SettingsNotifyPage(),
                                ),
                                isExpanded: !item.isExpanded);
                        }
                      }).toList()),
                ],
              ),
            ),
            Visibility(
              visible: !kDebugMode,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FutureBuilder<PackageInfo>(
                      future: context.read<AppInfoProvider>().getVersionName(),
                      builder: (BuildContext context,
                          AsyncSnapshot<PackageInfo> snapshot) {
                        return Text(
                            '${snapshot.data?.version}-${snapshot.data?.buildNumber}');
                      }),
                ),
              ),
            )
          ],
        ));
  }
}
