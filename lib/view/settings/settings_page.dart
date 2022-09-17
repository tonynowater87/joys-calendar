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
                          body: SizedBox(
                            width: double.infinity,
                            height: 100,
                            child: BlocBuilder<SettingsBloc, SettingsState>(
                              builder: (context, state) {
                                final children = state.settingEventItems
                                    .map(
                                      (e) => Center(
                                        child: SizedBox(
                                          width: 150,
                                          height: 50,
                                          child: CheckboxListTile(
                                            value: e.isSelected,
                                            title: Text(e.eventType.name),
                                            onChanged: (bool? isChecked) {
                                              if (isChecked == true) {
                                                context
                                                    .read<SettingsBloc>()
                                                    .add(AddFilterEvent(
                                                        eventType:
                                                            e.eventType));
                                              } else if (isChecked == false) {
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
                                        ),
                                      ),
                                    )
                                    .toList();
                                return ListView.builder(
                                  itemBuilder: (context, position) {
                                    return children[position];
                                  },
                                  scrollDirection: Axis.horizontal,
                                  itemCount: children.length,
                                );
                              },
                            ),
                          ),
                          isExpanded: item.isExpanded);
                    case SettingType.locale:
                      return ExpansionPanel(
                          headerBuilder: (context, bool isExpanded) {
                            return ListTile(
                                title: Text(item.headerValue.toLocalization()));
                          },
                          body: const ListTile(title: Text('施工中')),
                          isExpanded: item.isExpanded);
                  }
                }).toList()),
          ),
        ));
  }
}
