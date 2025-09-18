class UserPreferences {
  final bool notifications;
  final bool darkMode;
  final String language;

  UserPreferences({
    required this.notifications,
    required this.darkMode,
    required this.language,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notifications: map['notifications'] ?? true,
      darkMode: map['darkMode'] ?? true,
      language: map['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'darkMode': darkMode,
      'language': language,
    };
  }
}