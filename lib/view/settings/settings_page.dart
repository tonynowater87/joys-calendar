import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/common/configs/colors.dart';
import 'package:joys_calendar/repo/app_info_provider.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<SettingsTitleItem> settingsItem = [
    SettingsTitleItem(SettingType.eventType, false),
    SettingsTitleItem(SettingType.locale, false)
  ];

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
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
                                headerBuilder: (context, bool isExpanded) {
                                  return ListTile(
                                      title: Text(
                                          item.headerValue.toLocalization()));
                                },
                                body: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child:
                                      BlocBuilder<SettingsBloc, SettingsState>(
                                    builder: (context, state) {
                                      final children = state.settingEventItems
                                          .map(
                                            (e) => Row(
                                              children: [
                                                Text(e.eventType
                                                    .toSettingName()),
                                                Checkbox(
                                                  value: e.isSelected,
                                                  onChanged: (bool? isChecked) {
                                                    if (isChecked == true) {
                                                      context
                                                          .read<SettingsBloc>()
                                                          .add(AddFilterEvent(
                                                              eventType:
                                                                  e.eventType));
                                                    } else if (isChecked ==
                                                        false) {
                                                      context
                                                          .read<SettingsBloc>()
                                                          .add(RemoveFilterEvent(
                                                              eventType:
                                                                  e.eventType));
                                                    } else {
                                                      context
                                                          .read<SettingsBloc>()
                                                          .add(AddFilterEvent(
                                                              eventType:
                                                                  e.eventType));
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList();
                                      return GridView.count(
                                          primary: false,
                                          padding: const EdgeInsets.all(5),
                                          crossAxisCount: 3,
                                          shrinkWrap: true,
                                          children: children);
                                    },
                                  ),
                                ),
                                isExpanded: item.isExpanded);
                          case SettingType.locale:
                            return ExpansionPanel(
                                headerBuilder: (context, bool isExpanded) {
                                  return ListTile(
                                      title: Text(
                                          item.headerValue.toLocalization()));
                                },
                                body: const ListTile(title: Text('施工中...')),
                                isExpanded: item.isExpanded);
                        }
                      }).toList()),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      AnimatedButton(
                          width: 100,
                          height: 50,
                          color: AppColors.lightGreen,
                          onPressed: () {
                            // TODO
                          },
                          child: const Text('備份資料')),
                      const SizedBox(
                        width: 10,
                      ),
                      AnimatedButton(
                          width: 100,
                          height: 50,
                          color: AppColors.lightGreen,
                          onPressed: () {
                            // TODO
                          },
                          child: const Text('恢復資料')),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
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
            )
          ],
        ));
  }
}
