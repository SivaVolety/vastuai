import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/processing_mode_selector.dart';
import '../services/vastu_api_service.dart';
import '../services/analysis_history_service.dart';
import '../services/api_config.dart';
import 'package:provider/provider.dart';
import '../providers/rule_set_provider.dart';
import '../providers/advanced_settings_provider.dart';
import '../widgets/cross_overlay.dart';
import 'result_page.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import '../widgets/model_selector.dart';
import '../providers/model_selection_provider.dart';
import '../models/detector_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _imageFile;
  Uint8List? _imageBytes;
  int _rotation = 0;
  bool _isLoading = false;
  bool _showOverlay = true;

  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _previewContainerKey = GlobalKey();
  double _currentScale = 1.0;

  Future<void> _selectImageSource() async {
    if (kIsWeb) {
      await _pickImageFromSource(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
        _rotation = 0;
        _resetZoom();
      });
    }
  }

  void _rotateClockwise() {
    setState(() {
      _rotation = (_rotation + 30) % 360;
    });
  }

  void _rotateCounterClockwise() {
    setState(() {
      _rotation = (_rotation - 30) % 360;
      if (_rotation < 0) _rotation += 360;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    _currentScale = 1.0;
  }

  void _toggleZoom(double factor) {
    setState(() {
      if (_currentScale <= 1.0) {
        _currentScale = factor;
      } else {
        _currentScale = 1.0;
      }
      _transformationController.value = Matrix4.identity()
        ..scaleByDouble(_currentScale, _currentScale, _currentScale, 1.0);
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _isLoading) return;
    final provider = Provider.of<RuleSetProvider>(context, listen: false);
    final advanced = Provider.of<AdvancedSettingsProvider>(context, listen: false);
    final selectedModel = context.read<ModelSelectionProvider>().selected;
    setState(() => _isLoading = true);

    try {
      // Hide overlay
      setState(() => _showOverlay = false);
      await Future.delayed(const Duration(milliseconds: 100)); // ensure rebuild

      // Capture widget image
      RenderRepaintBoundary boundary = _previewContainerKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // --- BEGIN IMAGE RESIZING ---                                                                                                                                    │
      // Decode the image                                                                                                                                                │
      img.Image? originalImage = img.decodeImage(pngBytes);

      if (originalImage == null) {
        throw Exception("Failed to decode image for resizing.");
      }

      // Resize the image to 640x640
      final resizedImage = img.copyResize(
        originalImage,
        width: 640,
        height: 640,
        interpolation: img.Interpolation.average,
      );

      // Re-encode to PNG
      final resizedPngBytes = img.encodePng(resizedImage);
      // --- END IMAGE RESIZING ---

      // Show overlay again
      setState(() => _showOverlay = true);

      final jsonResponse = await VastuApiService().uploadBytes(
        Uint8List.fromList(resizedPngBytes),
        filename: 'transformed_image.png',
        ruleSetName: provider.selected ?? 'Vastu Presets',
        rules: await provider.selectedRules,
        confidenceThreshold: advanced.confidenceThreshold,
        showBoundingBoxes: advanced.showBoundingBoxes,
        modelVersion: selectedModel.name,
      );
      final reportedModel = DetectorModel.fromVersion(jsonResponse['model_version']);
      final imageUrl = jsonResponse['image_url'] as String;
      final vastuReport = jsonResponse['vastu_report'] as List;
      final baseUrl = await ApiConfig.getBaseUrl();
      final resolvedImageUrl = imageUrl.startsWith('http') ? imageUrl : '$baseUrl$imageUrl';
      // History is best-effort: a local persistence failure must not hide a
      // successful analysis from the user.
      if (!kIsWeb) {
        await AnalysisHistoryService().saveRemoteResult(
          imageUrl: resolvedImageUrl,
          ruleSetName: jsonResponse['rule_set_name'] as String? ?? provider.selected ?? 'Vastu Presets',
          report: List<Map<String, dynamic>>.from(vastuReport),
          confidenceThreshold: advanced.confidenceThreshold,
          showConfidence: advanced.showConfidence,
          showBoundingBoxes: advanced.showBoundingBoxes,
          modelVersion: reportedModel?.name,
        );
      }
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              imageUrl: resolvedImageUrl,
              vastuReport: List<Map<String, dynamic>>.from(vastuReport),
              ruleSetName: jsonResponse['rule_set_name'] as String?,
              showConfidence: advanced.showConfidence,
              modelVersion: reportedModel?.name,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showOverlay = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floor Plan Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _selectImageSource,
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 10),
              if (_imageFile != null)
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RepaintBoundary(
                        key: _previewContainerKey,
                        child: ClipRect(
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            clipBehavior: Clip.none,
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 5.0,
                            child: Center(
                              child: GestureDetector(
                                onDoubleTap: () => _toggleZoom(2.5),
                                child: Transform.rotate(
                                  angle: _rotation * math.pi / 180,
                                  child: _imageBytes == null
                                      ? const SizedBox.shrink()
                                      : Image.memory(_imageBytes!, fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_showOverlay)
                        IgnorePointer(child: const CrossOverlay()),
                      const Positioned(top: 8, right: 8, child: Text('N ↑', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              if (_imageFile != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _isLoading ? null : _rotateCounterClockwise,
                      icon: const Icon(Icons.rotate_left),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : _rotateClockwise,
                      icon: const Icon(Icons.rotate_right),
                    ),
                    IconButton(
                      onPressed: _resetZoom,
                      icon: const Icon(Icons.center_focus_strong),
                      tooltip: 'Reset Zoom',
                    ),
                  ],
                ),
              ProcessingModeSelector(),
              ModelSelector(enabled: !_isLoading),
              const Text('Rotate the floor plan until North is facing up.'),
              ElevatedButton(
                onPressed:
                    (_imageFile == null || _isLoading) ? null : _uploadImage,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Analyze'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
