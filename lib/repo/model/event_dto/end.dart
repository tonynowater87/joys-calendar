import 'dart:convert';

class End {
  String? date;

  End({this.date});

  @override
  String toString() => 'End(date: $date)';

  factory End.fromMap(Map<String, dynamic> data) => End(
        date: data['date'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'date': date,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [End].
  factory End.fromJson(String data) {
    return End.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [End] to a JSON string.
  String toJson() => json.encode(toMap());
}
