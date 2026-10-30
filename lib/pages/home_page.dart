import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
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
import '../providers/model_selection_provider.dart';
import '../models/detector_model.dart';
import '../theme/vastu_theme.dart';
import '../widgets/botanical_background.dart';
import '../widgets/analyzer/analyzer_hero.dart';
import '../widgets/analyzer/floor_plan_card.dart';
import '../widgets/analyzer/analysis_setup_card.dart';

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
    final advanced =
        Provider.of<AdvancedSettingsProvider>(context, listen: false);
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
      final reportedModel =
          DetectorModel.fromVersion(jsonResponse['model_version']);
      final imageUrl = jsonResponse['image_url'] as String;
      final vastuReport = jsonResponse['vastu_report'] as List;
      final baseUrl = await ApiConfig.getBaseUrl();
      final resolvedImageUrl =
          imageUrl.startsWith('http') ? imageUrl : '$baseUrl$imageUrl';
      // History is best-effort: a local persistence failure must not hide a
      // successful analysis from the user.
      if (!kIsWeb) {
        await AnalysisHistoryService().saveRemoteResult(
          imageUrl: resolvedImageUrl,
          ruleSetName: jsonResponse['rule_set_name'] as String? ??
              provider.selected ??
              'Vastu Presets',
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Widget _preview() => Stack(fit: StackFit.expand, children: [
        RepaintBoundary(
          key: _previewContainerKey,
          child: ColoredBox(
            color: Colors.white,
            child: ClipRect(
                child: InteractiveViewer(
              transformationController: _transformationController,
              clipBehavior: Clip.hardEdge,
              panEnabled: true,
              minScale: 0.5,
              maxScale: 5.0,
              onInteractionEnd: (_) {
                _currentScale =
                    _transformationController.value.getMaxScaleOnAxis();
              },
              child: Center(
                  child: GestureDetector(
                onDoubleTap: () => _toggleZoom(2.5),
                child: Transform.rotate(
                  angle: _rotation * math.pi / 180,
                  child: _imageBytes == null
                      ? const SizedBox.shrink()
                      : Image.memory(_imageBytes!, fit: BoxFit.contain),
                ),
              )),
            )),
          ),
        ),
        if (_showOverlay) const IgnorePointer(child: CrossOverlay()),
      ]);

  void _zoomBy(double factor) {
    setState(() {
      final next = (_currentScale * factor).clamp(0.5, 5.0);
      _transformationController.value = _transformationController.value.clone()
        ..scaleByDouble(next / _currentScale, next / _currentScale,
            next / _currentScale, 1);
      _currentScale = next;
    });
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth >= VastuLayout.desktop;
        final inset = desktop
            ? (constraints.maxWidth >= 1280 ? VastuSpace.page : VastuSpace.xxl)
            : VastuSpace.lg;
        final canManipulate = _imageFile != null && !_isLoading;
        final floorPlan = FloorPlanCard(
          desktop: desktop,
          hasImage: _imageFile != null,
          filename: _imageFile?.name,
          preview: _preview(),
          rotation: _rotation,
          onUpload: _isLoading ? null : _selectImageSource,
          onRotateLeft: canManipulate ? _rotateCounterClockwise : null,
          onRotateRight: canManipulate ? _rotateClockwise : null,
          onZoomIn: canManipulate ? () => _zoomBy(1.25) : null,
          onZoomOut: canManipulate ? () => _zoomBy(0.8) : null,
          onReset: canManipulate ? _resetZoom : null,
        );
        final setup = AnalysisSetupCard(
          desktop: desktop,
          loading: _isLoading,
          onAnalyze: canManipulate ? _uploadImage : null,
          onRotateLeft: canManipulate ? _rotateCounterClockwise : null,
          onRotateRight: canManipulate ? _rotateClockwise : null,
        );
        return BotanicalBackground(
          contentInset: inset,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(inset, 0, inset, VastuSpace.section),
            child: Center(
                child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: VastuLayout.contentMax),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnalyzerHero(desktop: desktop),
                    if (desktop)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: floorPlan),
                            const SizedBox(width: VastuSpace.xl),
                            SizedBox(
                                width: VastuLayout.setupWidth, child: setup),
                          ])
                    else ...[
                      floorPlan,
                      const SizedBox(height: VastuSpace.xl),
                      setup,
                    ],
                    const SizedBox(height: VastuSpace.xl),
                    const Center(
                        child: Text('Thoughtful spaces. Informed decisions.',
                            style: VastuType.caption)),
                  ]),
            )),
          ),
        );
      });
}
