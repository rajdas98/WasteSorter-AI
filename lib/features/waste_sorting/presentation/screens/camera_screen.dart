// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wastesorter/features/waste_sorting/presentation/providers/waste_providers.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/result_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isCameraAvailable = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      if (!kIsWeb) {
        final PermissionStatus permission = await Permission.camera.request();
        if (!permission.isGranted) {
          print('Camera init failed: permission denied');
          setState(() {
            _isInitializing = false;
            _isCameraAvailable = false;
            _error = 'Camera permission denied. Please use gallery upload.';
          });
          return;
        }
      }

      final List<CameraDescription> cameras = await ref.read(camerasProvider.future);
      if (cameras.isEmpty) {
        print('Camera init failed: no camera hardware found');
        setState(() {
          _isInitializing = false;
          _isCameraAvailable = false;
          _error = 'No camera found. Please use gallery upload.';
        });
        return;
      }

      final CameraController controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isCameraAvailable = true;
        _isInitializing = false;
        _error = null;
      });
    } catch (e) {
      print('Camera init failed: $e');
      setState(() {
        _isInitializing = false;
        _isCameraAvailable = false;
        _error = 'Could not initialize camera. Use gallery upload.';
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing || !_isCameraAvailable) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      final bytes = await photo.readAsBytes();
      final String base64Image = base64Encode(bytes);

      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            imageBase64: base64Image,
            imagePath: photo.path,
          ),
        ),
      );
    } catch (e) {
      print('Capture failed: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image. Use gallery upload.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final XFile? selected = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (selected == null) {
        return;
      }
      final bytes = await selected.readAsBytes();
      final String base64Image = base64Encode(bytes);

      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            imageBase64: base64Image,
            imagePath: selected.path,
          ),
        ),
      );
    } catch (e) {
      print('Gallery pick failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not pick image from gallery.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Stack(
                    children: <Widget>[
                      if (_isCameraAvailable && _controller != null)
                        Positioned.fill(child: CameraPreview(_controller!))
                      else
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFF10271F),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _error ?? 'Camera unavailable on this device/browser.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (_isCameraAvailable)
                                GestureDetector(
                                  onTap: _captureImage,
                                  child: Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.2),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: _isCapturing
                                        ? const Padding(
                                            padding: EdgeInsets.all(22),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.camera, color: Colors.white, size: 34),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              FilledButton.icon(
                                onPressed: _pickFromGallery,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Gallery'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF169A6F),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (kIsWeb)
                        const Positioned(
                          top: 16,
                          right: 16,
                          child: Chip(
                            label: Text('Web mode'),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
