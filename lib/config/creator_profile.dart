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

  /// Bundled portrait path. Null or an image loading failure uses the monogram.
  final String? photoAsset;
  final String? email, github, linkedIn, website;
  static const current = CreatorProfile(
      photoAsset: 'assets/images/siva_profile.png',
      linkedIn: 'https://www.linkedin.com/in/siva-volety-108a44263');

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
