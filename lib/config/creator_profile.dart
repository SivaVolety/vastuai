/// Public creator information. Unconfigured values are hidden, never fake links.
class CreatorProfile {
  const CreatorProfile(
      {this.name = 'Siva Volety',
      this.photoAsset,
      this.email,
      this.github,
      this.linkedIn,
      this.website = 'https://vasthu.ai'});
  final String name;

  /// Add assets/images/siva_profile.jpg, declare it in pubspec.yaml, then set
  /// this field. Keep null until the real, approved portrait is available.
  final String? photoAsset;
  final String? email, github, linkedIn, website;
  static const current = CreatorProfile();

  Map<String, Uri> get contacts {
    final result = <String, Uri>{};
    if (email != null &&
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email!)) {
      result['Email'] = Uri(scheme: 'mailto', path: email);
    }
    for (final entry in {
      'GitHub': github,
      'LinkedIn': linkedIn,
      'Website': website
    }.entries) {
      final uri = Uri.tryParse(entry.value ?? '');
      if (uri != null &&
          uri.scheme == 'https' &&
          uri.host.isNotEmpty &&
          uri.userInfo.isEmpty) {
        result[entry.key] = uri;
      }
    }
    return result;
  }
}
