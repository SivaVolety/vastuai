import 'package:flutter/foundation.dart';
import '../models/detector_model.dart';

/// Session state: navigation preserves the choice; restarting defaults to V1.
class ModelSelectionProvider extends ChangeNotifier {
  DetectorModel selected = DetectorModel.v1;

  void select(DetectorModel model) {
    if (selected == model) return;
    selected = model;
    notifyListeners();
  }
}
