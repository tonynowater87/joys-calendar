import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';

class SettingsGridListView extends StatelessWidget {
  const SettingsGridListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2 / 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8),
              itemCount: state.settingEventItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = state.settingEventItems[index];
                return InkWell(
                  onTap: () {
                    if (item.isSelected) {
                      context
                          .read<SettingsBloc>()
                          .add(RemoveFilterEvent(eventType: item.eventType));
                    } else {
                      context
                          .read<SettingsBloc>()
                          .add(AddFilterEvent(eventType: item.eventType));
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.isSelected
                            ? item.eventType.toEventColor()
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            width: 2, color: item.eventType.toEventColor()),
                      ),
                      child: Text(item.eventType.toSettingName())),
                );
              });
        },
      ),
    );
  }
}
