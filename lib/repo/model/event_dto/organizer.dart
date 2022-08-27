import 'dart:convert';

class Organizer {
  String? email;
  String? displayName;
  bool? self;

  Organizer({this.email, this.displayName, this.self});

  @override
  String toString() {
    return 'Organizer(email: $email, displayName: $displayName, self: $self)';
  }

  factory Organizer.fromMap(Map<String, dynamic> data) => Organizer(
        email: data['email'] as String?,
        displayName: data['displayName'] as String?,
        self: data['self'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'self': self,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Organizer].
  factory Organizer.fromJson(String data) {
    return Organizer.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Organizer] to a JSON string.
  String toJson() => json.encode(toMap());
}
