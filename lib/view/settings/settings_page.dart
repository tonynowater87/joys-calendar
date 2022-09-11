import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_item.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';

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
                          body: BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, state) {
                              return Text('text');
                              // TODO can't display body row??
                              /*return Row(
                                  children: state.settingEventItems
                                      .map((e) => ListTile(
                                          title: Text(
                                              '${e.eventType}, ${e.isSelected}')))
                                      .toList());*/
                            },
                          ),
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
