import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'package:flutter_application_0/app_data.dart';
import 'app_settings.dart';
import 'app_drawer.dart';

class SignClassifierPage extends StatefulWidget {
  const SignClassifierPage({super.key});

  @override
  State<SignClassifierPage> createState() => _SignClassifierPageState();
}

class _SignClassifierPageState extends State<SignClassifierPage> {
  static const MethodChannel _mediapipeChannel = MethodChannel(
    'mediapipe_hand_landmarks',
  );

  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();

  Interpreter? _interpreter;
  List<String> _labels = [];

  List<double> _scalerMean = [];
  List<double> _scalerScale = [];

  bool _isModelLoaded = false;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;

  int _frameCount = 0;
  final int _processEveryNFrames = 10;

  String _predictedLabel = 'No prediction yet';
  double _confidence = 0.0;
  String _status = 'Loading landmark model...';

  File? _selectedImageFile;
  bool _usingLiveCamera = true;

  int _inputFeatures = 63;
  int _numClasses = 0;

  double get _confidenceThreshold => AppSettings.confidenceThreshold.value;

  final int _smoothingWindow = 5;
  final Queue<ClassificationResult> _recentPredictions =
      Queue<ClassificationResult>();

  List<PredictionItem> _topPredictions = [];

  // Text box state
  String _recognizedText = '';
  String _translatedText = '';

  // Text-to-speech
  final FlutterTts _flutterTts = FlutterTts();

  // Translation
  late final OnDeviceTranslator _translator;
  bool _isTranslating = false;
  String _currentTargetLanguage = AppSettings.translationLanguage.value;
  TranslateLanguage _targetLanguage = TranslateLanguage.arabic;

  @override
  void initState() {
    super.initState();

    if (_currentTargetLanguage == "French") {
      _targetLanguage = TranslateLanguage.french;
    } else if (_currentTargetLanguage == "Spanish") {
      _targetLanguage = TranslateLanguage.spanish;
    } else if (_currentTargetLanguage == "German") {
      _targetLanguage = TranslateLanguage.german;
    }

    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: _targetLanguage,
    );

    _initializeTts();
    _initializeAll();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initializeAll() async {
    try {
      await _loadModelLabelsAndScaler();
      await _initializeCamera();

      setState(() {
        _status = 'Ready';
      });
    } catch (e) {
      setState(() {
        _status = 'Initialization error: $e';
      });
    }
  }

  Future<void> _loadModelLabelsAndScaler() async {
    try {
      final modelBytes = await rootBundle.load(
        'assets/landmark_classifier.tflite',
      );
      debugPrint('LANDMARK MODEL BYTES = ${modelBytes.lengthInBytes}');

      final labelsData = await rootBundle.loadString(
        'assets/landmark_labels.txt',
      );

      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final scalerData = await rootBundle.loadString(
        'assets/landmark_scaler_mean_std.json',
      );
      final scalerJson = jsonDecode(scalerData) as Map<String, dynamic>;

      _scalerMean = (scalerJson['mean'] as List)
          .map((e) => (e as num).toDouble())
          .toList();

      _scalerScale = (scalerJson['scale'] as List)
          .map((e) => (e as num).toDouble())
          .toList();

      _interpreter = await Interpreter.fromAsset(
        'assets/landmark_classifier.tflite',
      );

      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;

      if (inputShape.length == 2) {
        _inputFeatures = inputShape[1];
      }

      if (outputShape.length == 2) {
        _numClasses = outputShape[1];
      } else {
        _numClasses = _labels.length;
      }

      debugPrint('Input shape: $inputShape');
      debugPrint('Output shape: $outputShape');
      debugPrint('Input features: $_inputFeatures');
      debugPrint('Labels count: ${_labels.length}');
      debugPrint('Scaler mean length: ${_scalerMean.length}');
      debugPrint('Scaler scale length: ${_scalerScale.length}');

      if (_inputFeatures != 63) {
        throw Exception(
          'Expected 63 landmark features, but model expects $_inputFeatures',
        );
      }

      if (_scalerMean.length != _inputFeatures ||
          _scalerScale.length != _inputFeatures) {
        throw Exception('Scaler size does not match model input size.');
      }

      if (_labels.length != _numClasses) {
        debugPrint(
          'WARNING: labels count (${_labels.length}) != model classes ($_numClasses)',
        );
      }

      setState(() {
        _isModelLoaded = true;
        _status = 'Landmark model loaded successfully';
      });
    } catch (e) {
      debugPrint('MODEL LOAD ERROR: $e');
      setState(() {
        _isModelLoaded = false;
        _status = 'Model load failed: $e';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Load cameras here if they were not loaded in main.dart.
      if (globalCameras.isEmpty) {
        globalCameras = await availableCameras();
      }

      if (globalCameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _status = 'No camera found on this device';
        });
        return;
      }

      final preferredDirection = AppSettings.useFrontCamera.value
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      final selectedCamera = globalCameras.firstWhere(
        (camera) => camera.lensDirection == preferredDirection,
        orElse: () => globalCameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      await _cameraController!.startImageStream((CameraImage image) async {
        if (!_usingLiveCamera) return;
        if (!_isModelLoaded) return;
        if (_isProcessingFrame) return;

        _frameCount++;
        if (_frameCount % _processEveryNFrames != 0) return;

        _isProcessingFrame = true;

        try {
          await _classifyCameraFrame(image);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _status = 'Frame error: $e';
          });
        } finally {
          _isProcessingFrame = false;
        }
      });

      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _status = 'Camera initialized';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = false;
        _status = 'Camera initialization error: $e';
      });
    }
  }

  Future<void> _classifyCameraFrame(CameraImage cameraImage) async {
    final rgbImage = _convertYUV420ToImage(cameraImage);

    final rotatedImage = img.copyRotate(rgbImage, angle: 90);

    final jpgBytes = img.encodeJpg(rotatedImage, quality: 90);

    final landmarks = await _detectLandmarksFromBytes(
      Uint8List.fromList(jpgBytes),
    );

    if (landmarks == null) {
      if (!mounted) return;
      setState(() {
        _predictedLabel = 'No hand detected';
        _confidence = 0.0;
        _topPredictions = [];
        _status = 'MediaPipe did not detect a hand';
        _selectedImageFile = null;
      });
      return;
    }

    final rawResult = _runLandmarkInference(landmarks, applyThreshold: true);

    final result = _getSmoothedPrediction(rawResult);

    if (!mounted) return;

    setState(() {
      _predictedLabel = result.label;
      _confidence = result.confidence;
      _topPredictions = result.topPredictions;
      _status = 'Live landmark classification';
      _selectedImageFile = null;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (!_isModelLoaded || _interpreter == null) {
        setState(() {
          _status = 'Model is not loaded yet';
        });
        return;
      }

      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      _usingLiveCamera = false;
      _recentPredictions.clear();

      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _selectedImageFile = file;
        _status = 'Detecting hand landmarks...';
      });

      final landmarks = await _detectLandmarksFromBytes(bytes);

      if (landmarks == null) {
        setState(() {
          _predictedLabel = 'No hand detected';
          _confidence = 0.0;
          _topPredictions = [];
          _status = 'MediaPipe did not detect a hand in the selected image';
        });
        return;
      }

      final result = _runLandmarkInference(landmarks, applyThreshold: false);

      setState(() {
        _predictedLabel = result.label;
        _confidence = result.confidence;
        _topPredictions = result.topPredictions;
        _status = 'Gallery landmark classification';
      });
    } catch (e) {
      setState(() {
        _status = 'Gallery error: $e';
      });
    }
  }

  Future<List<double>?> _detectLandmarksFromBytes(Uint8List imageBytes) async {
    try {
      final result = await _mediapipeChannel
          .invokeMethod<Map<dynamic, dynamic>>('detectHandLandmarks', {
            'imageBytes': imageBytes,
          });

      if (result == null) return null;

      final landmarksRaw = result['landmarks'];

      if (landmarksRaw == null) return null;

      final landmarks = (landmarksRaw as List)
          .map((e) => (e as num).toDouble())
          .toList();

      if (landmarks.length != _inputFeatures) {
        debugPrint(
          'Invalid landmark length: ${landmarks.length}, expected $_inputFeatures',
        );
        return null;
      }

      return landmarks;
    } catch (e) {
      debugPrint('MediaPipe channel error: $e');
      return null;
    }
  }

  ClassificationResult _runLandmarkInference(
    List<double> landmarks, {
    required bool applyThreshold,
  }) {
    if (_interpreter == null || !_isModelLoaded) {
      return const ClassificationResult(
        label: 'Model not loaded',
        confidence: 0,
        topPredictions: [],
      );
    }

    final scaledLandmarks = <double>[];

    for (int i = 0; i < landmarks.length; i++) {
      final scale = _scalerScale[i] == 0 ? 1.0 : _scalerScale[i];
      scaledLandmarks.add((landmarks[i] - _scalerMean[i]) / scale);
    }

    final input = [scaledLandmarks];
    final output = List.generate(1, (_) => List<double>.filled(_numClasses, 0));

    _interpreter!.run(input, output);

    final scores = output[0];

    int bestIndex = 0;
    double bestScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    final topPredictions = _buildTopPredictions(scores);

    if (applyThreshold && bestScore < _confidenceThreshold) {
      return ClassificationResult(
        label: 'Low confidence',
        confidence: bestScore,
        topPredictions: topPredictions,
      );
    }

    final label = bestIndex < _labels.length ? _labels[bestIndex] : 'Unknown';

    return ClassificationResult(
      label: label,
      confidence: bestScore,
      topPredictions: topPredictions,
    );
  }

  List<PredictionItem> _buildTopPredictions(List<double> scores) {
    final indexedScores = <PredictionItem>[];

    for (int i = 0; i < scores.length; i++) {
      final label = i < _labels.length ? _labels[i] : 'Unknown';
      indexedScores.add(PredictionItem(label: label, confidence: scores[i]));
    }

    indexedScores.sort((a, b) => b.confidence.compareTo(a.confidence));

    return indexedScores.take(3).toList();
  }

  ClassificationResult _getSmoothedPrediction(ClassificationResult newResult) {
    _recentPredictions.addLast(newResult);

    while (_recentPredictions.length > _smoothingWindow) {
      _recentPredictions.removeFirst();
    }

    final Map<String, int> labelCounts = {};
    final Map<String, double> confidenceSums = {};

    for (final result in _recentPredictions) {
      labelCounts[result.label] = (labelCounts[result.label] ?? 0) + 1;
      confidenceSums[result.label] =
          (confidenceSums[result.label] ?? 0.0) + result.confidence;
    }

    String bestLabel = newResult.label;
    int bestCount = 0;
    double bestAverageConfidence = newResult.confidence;

    for (final label in labelCounts.keys) {
      final count = labelCounts[label]!;
      final avgConfidence = confidenceSums[label]! / count;

      if (count > bestCount) {
        bestCount = count;
        bestLabel = label;
        bestAverageConfidence = avgConfidence;
      } else if (count == bestCount && avgConfidence > bestAverageConfidence) {
        bestLabel = label;
        bestAverageConfidence = avgConfidence;
      }
    }

    return ClassificationResult(
      label: bestLabel,
      confidence: bestAverageConfidence,
      topPredictions: newResult.topPredictions,
    );
  }

  // ======================================================
  // TEXT BOX LOGIC
  // ======================================================

  bool _isWritablePrediction(String label) {
    final cleanLabel = label.trim().toLowerCase();

    if (cleanLabel.isEmpty) return false;
    if (cleanLabel == 'no prediction yet') return false;
    if (cleanLabel == 'no hand detected') return false;
    if (cleanLabel == 'low confidence') return false;
    if (cleanLabel == 'model not loaded') return false;
    if (cleanLabel == 'unknown') return false;
    if (cleanLabel == 'nothing') return false;

    return true;
  }

  bool _hasValidPrediction() {
    return _isWritablePrediction(_predictedLabel);
  }

  void _addCurrentPredictionToTextBox() {
    final label = _predictedLabel.trim();
    final confidence = _confidence;

    if (!_isWritablePrediction(label)) {
      setState(() {
        _status = 'No valid sign to add';
      });
      return;
    }

    if (confidence < _confidenceThreshold) {
      setState(() {
        _status = 'Prediction confidence is too low';
      });
      return;
    }

    setState(() {
      final lowerLabel = label.toLowerCase();

      if (lowerLabel == 'del') {
        if (_recognizedText.isNotEmpty) {
          _recognizedText = _recognizedText.substring(
            0,
            _recognizedText.length - 1,
          );
        }
      } else if (lowerLabel == 'space') {
        _recognizedText += ' ';
      } else if (label.length == 1) {
        _recognizedText += label.toUpperCase();
      } else {
        _status = 'This sign cannot be written into the text box';
        return;
      }

      _translatedText = '';
      _status = 'Added "$label" to text box';
    });
  }

  void _deleteLastCharacter() {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _recognizedText = _recognizedText.substring(
        0,
        _recognizedText.length - 1,
      );
      _translatedText = '';
      _status = 'Deleted last character';
    });
  }

  void _clearRecognizedText() {
    setState(() {
      _recognizedText = '';
      _translatedText = '';
      _status = 'Text box cleared';
    });
  }

  Future<void> _speakRecognizedText() async {
    final text = _recognizedText.trim();

    if (text.isEmpty) {
      setState(() {
        _status = 'Text box is empty';
      });
      return;
    }

    await _flutterTts.stop();
    await _flutterTts.speak(text);

    setState(() {
      _status = 'Speaking text';
    });
  }

  Future<void> _translateRecognizedText() async {
    final text = _recognizedText.trim();

    if (text.isEmpty) {
      setState(() {
        _status = 'Text box is empty';
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _status = 'Translating text...';
    });

    try {
      final translated = await _translator.translateText(text);

      setState(() {
        _translatedText = translated;
        _status = 'Translation complete';
      });
    } catch (e) {
      setState(() {
        _status =
            'Translation failed. The language model may need internet for first download.';
      });
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _resumeLiveCamera() {
    _recentPredictions.clear();

    setState(() {
      _usingLiveCamera = true;
      _selectedImageFile = null;
      _predictedLabel = 'No prediction yet';
      _confidence = 0.0;
      _topPredictions = [];
      _status = 'Live camera resumed';
    });
  }

  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final image = img.Image(width: width, height: height);

    final Plane yPlane = cameraImage.planes[0];
    final Plane uPlane = cameraImage.planes[1];
    final Plane vPlane = cameraImage.planes[2];

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      final int uvRow = uvRowStride * (y >> 1);
      final int yRow = yRowStride * y;

      for (int x = 0; x < width; x++) {
        final int uvIndex = uvRow + (x >> 1) * uvPixelStride;
        final int yIndex = yRow + x;

        final int yp = yPlane.bytes[yIndex];
        final int up = uPlane.bytes[uvIndex];
        final int vp = vPlane.bytes[uvIndex];

        int r = (yp + 1.402 * (vp - 128)).round();
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round();
        int b = (yp + 1.772 * (up - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    _flutterTts.stop();
    _translator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (_confidence * 100).toStringAsFixed(2);
    final hasPrediction = _hasValidPrediction();

    return Scaffold(
      appBar: AppBar(title: const Text('Detection'), centerTitle: true),
      drawer: const AppDrawer(currentPage: AppPage.prediction),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed small square camera preview
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.78,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildPreviewArea(),
                    ),
                  ),
                ),
              ),
            ),

            // Fixed prediction box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: _buildAnimatedPredictionBox(
                confidencePercent,
                hasPrediction,
              ),
            ),

            // Fixed thin top predictions box.
            // It appears only when there is a valid prediction.
            if (AppSettings.showTopPredictions.value &&
                _topPredictions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _buildThinTopPredictionsWidget(),
              ),

            // Only this lower section scrolls
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRecognizedTextBox(context),

                    const SizedBox(height: 12),

                    /*Text(
                      'Status: $_status',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),*/
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick from Gallery'),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _resumeLiveCamera,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Use Live Camera'),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPredictionBox(
    String confidencePercent,
    bool hasPrediction,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hasPrediction ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasPrediction ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPrediction ? 'Prediction Found' : 'Waiting for Sign',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasPrediction
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _predictedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasPrediction
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
            ),
            child: Text(
              '$confidencePercent%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: hasPrediction
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinTopPredictionsWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Top 3:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _topPredictions.map((item) {
                  final percent = (item.confidence * 100).toStringAsFixed(1);

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.10),
                      ),
                    ),
                    child: Text(
                      '${item.label} $percent%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizedTextBox(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.indigo),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 90),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.60),
                ),
              ),
              child: Text(
                _recognizedText.isEmpty
                    ? 'Selected letters will appear here...'
                    : _recognizedText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _recognizedText.isEmpty
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.63)
                      : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _addCurrentPredictionToTextBox,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Current Sign'),
                ),

                ElevatedButton.icon(
                  onPressed: _speakRecognizedText,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Speak'),
                ),

                OutlinedButton.icon(
                  onPressed: _deleteLastCharacter,
                  icon: const Icon(Icons.backspace),
                  label: const Text('Delete'),
                ),

                OutlinedButton.icon(
                  onPressed: _clearRecognizedText,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear All'),
                ),

                ElevatedButton.icon(
                  onPressed: _isTranslating ? null : _translateRecognizedText,
                  icon: const Icon(Icons.translate),
                  label: Text(_isTranslating ? 'Translating...' : 'Translate'),
                ),
              ],
            ),

            if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 14),

              const Text(
                'Translation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  _translatedText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    if (!_isModelLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedImageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _selectedImageFile!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          const Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Text(
              'Selected gallery image',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: Text('Initializing camera...'));
    }

    final previewSize = _cameraController!.value.previewSize;

    if (previewSize == null) {
      return CameraPreview(_cameraController!);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),

        const Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Text(
            'Show one hand clearly to the camera',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class ClassificationResult {
  final String label;
  final double confidence;
  final List<PredictionItem> topPredictions;

  const ClassificationResult({
    required this.label,
    required this.confidence,
    required this.topPredictions,
  });
}

class PredictionItem {
  final String label;
  final double confidence;

  const PredictionItem({required this.label, required this.confidence});
}
