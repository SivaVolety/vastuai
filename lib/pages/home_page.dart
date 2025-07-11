import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../widgets/cross_overlay.dart';
import 'result_page.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  int _rotation = 0;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _rotation = 0;
      });
    }
  }

  void _rotateClockwise() {
    setState(() {
      _rotation = (_rotation + 90) % 360;
    });
  }

  void _rotateCounterClockwise() {
    setState(() {
      _rotation = (_rotation - 90) % 360;
      if (_rotation < 0) _rotation += 360;
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Decode image
      final originalBytes = await _imageFile!.readAsBytes();
      img.Image originalImage = img.decodeImage(originalBytes)!;

      // Rotate
      img.Image rotatedImage;
      switch (_rotation) {
        case 90:
          rotatedImage = img.copyRotate(originalImage, angle: 90);
          break;
        case 180:
          rotatedImage = img.copyRotate(originalImage, angle: 180);
          break;
        case 270:
          rotatedImage = img.copyRotate(originalImage, angle: 270);
          break;
        default:
          rotatedImage = originalImage;
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final rotatedFilePath = '${tempDir.path}/rotated_image.jpg';
      final rotatedFile = File(rotatedFilePath)
        ..writeAsBytesSync(img.encodeJpg(rotatedImage));

      // Upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/upload-rotated'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          rotatedFile.path,
          filename: basename(rotatedFile.path),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final imageUrl = jsonResponse["image_url"] as String?;
        final vastuReport = jsonResponse["vastu_report"] as List?;

        if (imageUrl == null || vastuReport == null) {
          throw Exception("Invalid response from server");
        }

        Navigator.push(
          this.context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              imageUrl: 'http://127.0.0.1:8000$imageUrl',
              vastuReport: List<Map<String, dynamic>>.from(vastuReport),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Upload failed')),
        );
      }

      // Optional cleanup
      // await rotatedFile.delete();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                onPressed: _isLoading ? null : _pickImage,
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 10),
              if (_imageFile != null)
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _rotation * math.pi / 180,
                        child: Image.file(_imageFile!),
                      ),
                      const CrossOverlay(),
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
