import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joys_calendar/common/analytics/analytics_events.dart';
import 'package:joys_calendar/common/analytics/analytics_helper.dart';
import 'package:joys_calendar/repo/model/event_model.dart';
import 'package:joys_calendar/view/settings/settings_bloc.dart';
import 'package:joys_calendar/view/settings/settings_event.dart';
import 'package:joys_calendar/view/settings/settings_state.dart';

class SettingsGridListView extends StatelessWidget {
  const SettingsGridListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analyticsHelper = context.read<AnalyticsHelper>();
    return SizedBox(
      height: 200,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2 / 1,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4),
              itemCount: state.settingEventItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = state.settingEventItems[index];
                return InkWell(
                  onTap: () {
                    analyticsHelper
                        .logEvent(name: event_setting_country, parameters: {
                      event_setting_country_params_country_code_name:
                          item.eventType.toSettingName(),
                      event_setting_country_params_country_code_checked_name:
                          (!item.isSelected).toString(),
                    });
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
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.isSelected
                          ? item.eventType.toEventColor()
                          : Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          width: 2, color: item.eventType.toEventColor()),
                    ),
                    child: Text(
                      item.eventType.toSettingName(),
                      style: Theme.of(context).textTheme.button!.copyWith(
                          fontWeight: item.isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                              item.isSelected ? Colors.white : Colors.black38),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
