import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../widgets/cross_overlay.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  int _rotation = 0;
  bool _isLoading = false;
  bool _showOverlay = true;

  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _previewContainerKey = GlobalKey();
  double _currentScale = 1.0;

  Future<void> _selectImageSource() async {
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
                  Navigator.pop(this.context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(this.context);
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
      setState(() {
        _imageFile = File(picked.path);
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
        ..scale(_currentScale);
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _isLoading) return;
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

      // Show overlay again
      setState(() => _showOverlay = true);

      // Save to file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/transformed_image.png');
      await file.writeAsBytes(pngBytes);

      // Upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.79:8000/upload-rotated'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);

      setState(() => _isLoading = false);

      if (resBody.statusCode == 200) {
        final jsonResponse = json.decode(resBody.body);
        final imageUrl = jsonResponse["image_url"] as String?;
        final vastuReport = jsonResponse["vastu_report"] as List?;

        if (imageUrl == null || vastuReport == null) {
          throw Exception("Invalid response from server");
        }

        Navigator.push(
          this.context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              imageUrl: 'http://192.168.0.79:8000$imageUrl',
              vastuReport: List<Map<String, dynamic>>.from(vastuReport),
            ),
          ),
        );
      } else {
        throw Exception("Upload failed: ${resBody.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showOverlay = true;
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                                  child: Image.file(_imageFile!),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_showOverlay)
                        IgnorePointer(child: const CrossOverlay()),
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
