import 'dart:convert';

import 'item.dart';

class EventDto {
  String? kind;
  String? etag;
  String? summary;
  DateTime? updated;
  String? timeZone;
  String? accessRole;
  List<dynamic>? defaultReminders;
  String? nextSyncToken;
  String? nextPageToken;
  List<Item>? items;

  EventDto({
    this.kind,
    this.etag,
    this.summary,
    this.updated,
    this.timeZone,
    this.accessRole,
    this.defaultReminders,
    this.nextSyncToken,
    this.nextPageToken,
    this.items,
  });

  @override
  String toString() {
    return 'EventDto(kind: $kind, etag: $etag, summary: $summary, updated: $updated, timeZone: $timeZone, accessRole: $accessRole, defaultReminders: $defaultReminders, nextSyncToken: $nextSyncToken, nextPageToken: $nextPageToken, items: $items)';
  }

  factory EventDto.fromJson(Map<String, dynamic> data) => EventDto(
    kind: data['kind'] as String?,
    etag: data['etag'] as String?,
    summary: data['summary'] as String?,
    updated: data['updated'] == null
        ? null
        : DateTime.parse(data['updated'] as String),
    timeZone: data['timeZone'] as String?,
    accessRole: data['accessRole'] as String?,
    defaultReminders: data['defaultReminders'] as List<dynamic>?,
    nextSyncToken: data['nextSyncToken'] as String?,
    nextPageToken: data['nextPageToken'] as String?,
    items: (data['items'] as List<dynamic>?)
        ?.map((e) => Item.fromMap(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'kind': kind,
    'etag': etag,
    'summary': summary,
    'updated': updated?.toIso8601String(),
    'timeZone': timeZone,
    'accessRole': accessRole,
    'defaultReminders': defaultReminders,
    'nextSyncToken': nextSyncToken,
    'nextPageToken': nextPageToken,
    'items': items?.map((e) => e.toMap()).toList(),
  };

  /// `dart:convert`
  ///
  /// Converts [EventDto] to a JSON string.
  String toJson() => json.encode(toMap());
}
