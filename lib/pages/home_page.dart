// lib/pages/home_page.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
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
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() => _isLoading = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/upload-rotated'), // Change if needed
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        _imageFile!.path,
        filename: basename(_imageFile!.path),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final html = response.body;
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => ResultPage(htmlContent: html)),
      );
    } else {
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floor Plan Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
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
                    onPressed: _rotateCounterClockwise,
                    icon: const Icon(Icons.rotate_left),
                  ),
                  IconButton(
                    onPressed: _rotateClockwise,
                    icon: const Icon(Icons.rotate_right),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Analyze'),
            ),
          ],
        ),
      ),
    );
  }
}
