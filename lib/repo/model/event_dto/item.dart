import 'dart:convert';

import 'creator.dart';
import 'end.dart';
import 'organizer.dart';
import 'start.dart';

class Item {
  String? kind;
  String? etag;
  String? id;
  String? status;
  String? htmlLink;
  DateTime? created;
  DateTime? updated;
  String? summary;
  String? description;
  Creator? creator;
  Organizer? organizer;
  Start? start;
  End? end;
  String? transparency;
  String? visibility;
  String? iCalUid;
  int? sequence;
  String? eventType;

  Item({
    this.kind,
    this.etag,
    this.id,
    this.status,
    this.htmlLink,
    this.created,
    this.updated,
    this.summary,
    this.description,
    this.creator,
    this.organizer,
    this.start,
    this.end,
    this.transparency,
    this.visibility,
    this.iCalUid,
    this.sequence,
    this.eventType,
  });

  @override
  String toString() {
    return 'Item(kind: $kind, etag: $etag, id: $id, status: $status, htmlLink: $htmlLink, created: $created, updated: $updated, summary: $summary, description: $description, creator: $creator, organizer: $organizer, start: $start, end: $end, transparency: $transparency, visibility: $visibility, iCalUid: $iCalUid, sequence: $sequence, eventType: $eventType)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        kind: data['kind'] as String?,
        etag: data['etag'] as String?,
        id: data['id'] as String?,
        status: data['status'] as String?,
        htmlLink: data['htmlLink'] as String?,
        created: data['created'] == null
            ? null
            : DateTime.parse(data['created'] as String),
        updated: data['updated'] == null
            ? null
            : DateTime.parse(data['updated'] as String),
        summary: data['summary'] as String?,
        description: data['description'] as String?,
        creator: data['creator'] == null
            ? null
            : Creator.fromMap(data['creator'] as Map<String, dynamic>),
        organizer: data['organizer'] == null
            ? null
            : Organizer.fromMap(data['organizer'] as Map<String, dynamic>),
        start: data['start'] == null
            ? null
            : Start.fromMap(data['start'] as Map<String, dynamic>),
        end: data['end'] == null
            ? null
            : End.fromMap(data['end'] as Map<String, dynamic>),
        transparency: data['transparency'] as String?,
        visibility: data['visibility'] as String?,
        iCalUid: data['iCalUID'] as String?,
        sequence: data['sequence'] as int?,
        eventType: data['eventType'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'kind': kind,
        'etag': etag,
        'id': id,
        'status': status,
        'htmlLink': htmlLink,
        'created': created?.toIso8601String(),
        'updated': updated?.toIso8601String(),
        'summary': summary,
        'description': description,
        'creator': creator?.toMap(),
        'organizer': organizer?.toMap(),
        'start': start?.toMap(),
        'end': end?.toMap(),
        'transparency': transparency,
        'visibility': visibility,
        'iCalUID': iCalUid,
        'sequence': sequence,
        'eventType': eventType,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Item].
  factory Item.fromJson(String data) {
    return Item.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Item] to a JSON string.
  String toJson() => json.encode(toMap());
}
