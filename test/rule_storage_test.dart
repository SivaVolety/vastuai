import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/utils/rule_storage.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('built-in Vastu and Feng Shui presets are read-only', () async {
    expect(await RuleStorage.getRuleSetNames(), containsAll([
      'Vastu Presets', 'Feng Shui Compass Preset',
    ]));
    expect(RuleStorage.isBuiltIn('Vastu Presets'), isTrue);
    expect(RuleStorage.isBuiltIn('Feng Shui Compass Preset'), isTrue);
    await expectLater(RuleStorage.deleteRuleSet('Vastu Presets'), throwsArgumentError);
    await expectLater(RuleStorage.updateRuleSet('Feng Shui Compass Preset', {}), throwsArgumentError);
  });

  test('direction chips serialize normalized unique directions', () async {
    await RuleStorage.addRuleSet('Home', {'bed': ['sw', 'SW', 'n']});
    expect(await RuleStorage.getRulesForSet('Home'), {'bed': ['SW', 'N']});
  });

  test('Feng Shui water and fire mappings are conservative', () async {
    final rules = await RuleStorage.getRulesForSet('Feng Shui Compass Preset');
    expect(rules?['sink'], ['N']);
    expect(rules?['large_sink'], ['N']);
    expect(rules?['kitchen_bar'], ['S']);
    expect(rules?.containsKey('bed'), isFalse);
  });

  test('custom labels and empty directions can be validated by editor data', () async {
    expect(modelLabels, contains('large_sofa'));
    expect(directionOptions, hasLength(8));
    await RuleStorage.addRuleSet('Empty', {});
    expect(await RuleStorage.getRulesForSet('Empty'), isEmpty);
  });
}
