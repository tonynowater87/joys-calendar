import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/app_info_provider.dart';
import 'package:joys_calendar/view/settings/login/login_view.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_grid_list_view.dart';
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
    /*SettingsTitleItem(SettingType.locale, false)*/ // TODO future feature
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
                                body: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: SettingsGridListView(),
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
                    height: 200,
                    width: 400,
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: LoginView(),
                    ),
                  )
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
