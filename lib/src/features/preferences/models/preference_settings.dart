class PreferenceSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool locationServices;
  final bool darkMode;
  final List<String> interests;
  final Map<String, dynamic> customSettings;

  PreferenceSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.locationServices = false,
    this.darkMode = false,
    this.interests = const [],
    this.customSettings = const {},
  });

  factory PreferenceSettings.fromMap(Map<String, dynamic> map) {
    return PreferenceSettings(
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      locationServices: map['locationServices'] ?? false,
      darkMode: map['darkMode'] ?? false,
      interests: List<String>.from(map['interests'] ?? []),
      customSettings: Map<String, dynamic>.from(map['customSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'locationServices': locationServices,
      'darkMode': darkMode,
      'interests': interests,
      'customSettings': customSettings,
    };
  }

  PreferenceSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? locationServices,
    bool? darkMode,
    List<String>? interests,
    Map<String, dynamic>? customSettings,
  }) {
    return PreferenceSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      locationServices: locationServices ?? this.locationServices,
      darkMode: darkMode ?? this.darkMode,
      interests: interests ?? this.interests,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
