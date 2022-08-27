import 'dart:convert';

class Start {
  String? date;

  Start({this.date});

  @override
  String toString() => 'Start(date: $date)';

  factory Start.fromMap(Map<String, dynamic> data) => Start(
        date: data['date'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'date': date,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Start].
  factory Start.fromJson(String data) {
    return Start.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Start] to a JSON string.
  String toJson() => json.encode(toMap());
}
