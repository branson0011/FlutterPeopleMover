enum PreferenceCategory {
  interests,
  notifications,
  privacy,
  location,
  accessibility;

  String get displayName {
    switch (this) {
      case PreferenceCategory.interests:
        return 'Interests';
      case PreferenceCategory.notifications:
        return 'Notifications';
      case PreferenceCategory.privacy:
        return 'Privacy';
      case PreferenceCategory.location:
        return 'Location';
      case PreferenceCategory.accessibility:
        return 'Accessibility';
    }
  }

  List<String> get options {
    switch (this) {
      case PreferenceCategory.interests:
        return [
          'Sports & Recreation',
          'Arts & Culture',
          'Food & Dining',
          'Nightlife & Entertainment',
          'Shopping & Retail',
        ];
      case PreferenceCategory.notifications:
        return ['Push', 'Email', 'SMS', 'In-App'];
      case PreferenceCategory.privacy:
        return ['Public Profile', 'Show Location', 'Share Activity'];
      case PreferenceCategory.location:
        return ['Always', 'While Using', 'Never'];
      case PreferenceCategory.accessibility:
        return ['High Contrast', 'Large Text', 'Screen Reader'];
    }
  }
}
