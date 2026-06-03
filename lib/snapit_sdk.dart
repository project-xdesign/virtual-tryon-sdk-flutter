library snapit_sdk;

import 'package:flutter/material.dart';
import 'src/ui/theme/snapit_theme.dart';
import 'src/ui/screens/tryon_flow_screen.dart';

export 'src/ui/theme/snapit_theme.dart';
export 'src/client/exceptions.dart';
export 'src/client/api_client.dart';

class SnapIT {
  /// Opens the Try-On UI experience in the app.
  /// Launches a full-screen view where the user can capture/select a photo,
  /// triggers upload & try-on generation, and visualizes the results with an interactive slider.
  static void launchTryOnFlow({
    required BuildContext context,
    required String apiKey,
    required String userId,
    required String garmentImageUrl,
    String? productId,
    String? externalUserId,
    Map<String, dynamic>? metadata,
    String? modelName = 'fast',
    double? version = 1.1,
    SnapITTheme theme = const SnapITTheme(),
    Future<void> Function(String imageUrl)? onDownloadImage,
    required void Function(String resultImageUrl, String generationId)
        onSuccess,
    required void Function(String errorMessage) onFailure,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TryOnFlowScreen(
          apiKey: apiKey,
          userId: userId,
          garmentImageUrl: garmentImageUrl,
          productId: productId,
          externalUserId: externalUserId,
          metadata: metadata,
          modelName: modelName,
          version: version,
          sdkTheme: theme,
          onDownloadImage: onDownloadImage,
          onSuccess: onSuccess,
          onFailure: onFailure,
        ),
      ),
    );
  }
}
