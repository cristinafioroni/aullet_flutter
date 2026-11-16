class Profile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  String displayName;
  String? avatarUrl;

  Profile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.avatarUrl,
  });

  // Crea un'istanza di Profile a partire da una mappa
  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        firstName: map['first_name'] as String,
        lastName: map['last_name'] as String,
        displayName: map['display_name'] as String,
        avatarUrl: map['avatar_url'] as String?,
      );

  // Converte un oggetto Profile in una mappa
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };
}