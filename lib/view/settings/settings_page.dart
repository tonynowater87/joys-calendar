import 'package:flutter/material.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<SettingsItem> settingsItem = [
    SettingsItem(SettingType.eventType, false),
    SettingsItem(SettingType.locale, false)
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: ExpansionPanelList(
                expansionCallback: (index, bool) {
                  setState(() {
                    print('[Tony] $index expanded=$bool');
                    settingsItem[index].isExpanded = !bool;
                  });
                },
                children: settingsItem.map<ExpansionPanel>((item) {
                  switch (item.headerValue) {
                    case SettingType.eventType:
                      return ExpansionPanel(
                          headerBuilder: (context, bool isExpanded) {
                            return ListTile(
                                title: Text(item.headerValue.toLocalization()));
                          },
                          body: ListTile(title: Text('農曆(節氣)、台灣、日本、英國、美國...')),
                          isExpanded: item.isExpanded);
                    case SettingType.locale:
                      return ExpansionPanel(
                          headerBuilder: (context, bool isExpanded) {
                            return ListTile(
                                title: Text(item.headerValue.toLocalization()));
                          },
                          body: ListTile(title: Text('中、日、英')),
                          isExpanded: item.isExpanded);
                  }
                }).toList()),
          ),
        ));
  }
}
