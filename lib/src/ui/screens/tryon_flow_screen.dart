import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../client/api_client.dart';
import '../../ui/theme/snapit_theme.dart';
import '../../ui/widgets/before_after_slider.dart';

enum FlowStep { capture, processing, results }

class TryOnFlowScreen extends StatefulWidget {
  final String apiKey;
  final String userId;
  final String garmentImageUrl;
  final String? productId;
  final String? externalUserId;
  final Map<String, dynamic>? metadata;
  final SnapITTheme sdkTheme;
  final String? modelName;
  final double? version;
  final Future<void> Function(String imageUrl)? onDownloadImage;
  final void Function(String resultImageUrl, String generationId) onSuccess;
  final void Function(String errorMessage) onFailure;

  const TryOnFlowScreen({
    Key? key,
    required this.apiKey,
    required this.userId,
    required this.garmentImageUrl,
    this.modelName,
    this.version,
    this.productId,
    this.externalUserId,
    this.metadata,
    required this.sdkTheme,
    this.onDownloadImage,
    required this.onSuccess,
    required this.onFailure,
  }) : super(key: key);

  @override
  State<TryOnFlowScreen> createState() => _TryOnFlowScreenState();
}

class _TryOnFlowScreenState extends State<TryOnFlowScreen> {
  FlowStep _currentStep = FlowStep.capture;
  File? _capturedImage;
  String? _personImageUrl;
  String? _resultImageUrl;
  String? _generationId;
  String _loadingMessage = "";
  bool _isDownloading = false;

  late final SnapITClient _apiClient;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _apiClient = SnapITClient(apiKey: widget.apiKey, userId: widget.userId);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        _processTryOn();
      }
    } catch (e) {
      widget.onFailure(e.toString());
    }
  }

  Future<void> _processTryOn() async {
    if (_capturedImage == null) return;

    setState(() {
      _currentStep = FlowStep.processing;
      _loadingMessage = "Uploading your photo...";
    });

    try {
      // 1. Upload person photo
      final uploadedUrl = await _apiClient.uploadPersonImage(_capturedImage!);
      setState(() {
        _personImageUrl = uploadedUrl;
        _loadingMessage = "Generating try-on output...";
      });

      // 2. Call VTON try-on generation API
      final outputUrl = await _apiClient.generateTryOn(
        garmentImageUrl: widget.garmentImageUrl,
        personImageUrl: uploadedUrl,
        productId: widget.productId,
        externalUserId: widget.externalUserId,
        metadata: widget.metadata,
        modelName: widget.modelName,
        version: widget.version,
      );

      setState(() {
        _resultImageUrl = outputUrl;
        _generationId =
            "gen_${DateTime.now().millisecondsSinceEpoch}"; // Fallback unique ID
        _currentStep = FlowStep.results;
      });

      widget.onSuccess(outputUrl, _generationId!);
    } catch (e) {
      setState(() {
        _currentStep = FlowStep.capture;
      });
      widget.onFailure(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.sdkTheme.toThemeData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SnapIT Try-On'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case FlowStep.capture:
        return _buildCaptureUI();
      case FlowStep.processing:
        return _buildProcessingUI();
      case FlowStep.results:
        return _buildResultsUI();
    }
  }

  Widget _buildCaptureUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.sdkTheme.cardColor,
                borderRadius:
                    BorderRadius.circular(widget.sdkTheme.borderRadius),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.face_retouching_natural,
                      size: 72, color: Colors.white24),
                  const SizedBox(height: 24),
                  Text(
                    'Let\'s see how it looks on you!',
                    style: widget.sdkTheme
                        .toThemeData()
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Take a clear selfie or select a photo of yourself standing straight.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.sdkTheme.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(widget.sdkTheme.borderRadius),
              ),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture with Camera',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(widget.sdkTheme.borderRadius),
              ),
            ),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 300,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[900]!,
              highlightColor: Colors.grey[800]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _loadingMessage,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadImage() async {
    if (widget.onDownloadImage == null || _resultImageUrl == null) return;
    setState(() {
      _isDownloading = true;
    });
    try {
      await widget.onDownloadImage!(_resultImageUrl!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildResultsUI() {
    if (_personImageUrl == null || _resultImageUrl == null) {
      return const Center(child: Text("Invalid state"));
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.sdkTheme.borderRadius),
              child: BeforeAfterSlider(
                beforeImageUrl: _personImageUrl!,
                afterImageUrl: _resultImageUrl!,
                handleColor: widget.sdkTheme.primaryColor,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(widget.sdkTheme.borderRadius),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep = FlowStep.capture;
                      _capturedImage = null;
                      _personImageUrl = null;
                      _resultImageUrl = null;
                    });
                  },
                  child: const Text('Try Another'),
                ),
              ),
              if (widget.onDownloadImage != null) ...[
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(widget.sdkTheme.borderRadius),
                    ),
                  ),
                  onPressed: _isDownloading ? null : _downloadImage,
                  child: _isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                ),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.sdkTheme.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(widget.sdkTheme.borderRadius),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
