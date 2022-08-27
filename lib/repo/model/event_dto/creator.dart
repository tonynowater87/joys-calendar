import 'dart:convert';

class Creator {
  String? email;
  String? displayName;
  bool? self;

  Creator({this.email, this.displayName, this.self});

  @override
  String toString() {
    return 'Creator(email: $email, displayName: $displayName, self: $self)';
  }

  factory Creator.fromMap(Map<String, dynamic> data) => Creator(
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
  /// Parses the string and returns the resulting Json object as [Creator].
  factory Creator.fromJson(String data) {
    return Creator.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Creator] to a JSON string.
  String toJson() => json.encode(toMap());
}
