enum DetectorModel {
  v1('Stable V1', 'Stable V1 — Recommended'),
  v2('Experimental V2', 'Experimental V2 — Research Beta');

  const DetectorModel(this.label, this.selectorLabel);
  final String label;
  final String selectorLabel;

  static DetectorModel? fromVersion(Object? version) => switch (version) {
        'v1' => v1,
        'v2' => v2,
        _ => null,
      };

  static const betaWarning =
      'V2 is experimental and may be less accurate for some rare classes.';
  static const description =
      'V1 is the default stable detector. V2 is an experimental 9-class research '
      'model focused on bed, dining_table, main_entrance, stairs, stove, sink, '
      'toilet, tub, and kitchen_bar. V2 is still being evaluated and is not '
      'known to be more accurate overall.';
}
