import 'dart:io';
import 'package:dio/dio.dart';
import 'exceptions.dart';

class SnapITClient {
  final String apiKey;
  final String userId;
  final String baseUrl;
  final Dio _dio;

  SnapITClient({
    required this.apiKey,
    required this.userId,
    this.baseUrl = 'https://apisdk.snapmydesign.com/api/v1',
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'X-API-Key': apiKey,
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }

  /// Uploads target person image to cloud bucket
  Future<String> uploadPersonImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'userId': userId,
        'files':
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        '/vton/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final uploaded = response.data['uploaded'] as List;
        if (uploaded.isNotEmpty) {
          return uploaded.first['url'] as String;
        }
      }
      throw SnapITException('Failed to retrieve uploaded image URL');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generates the Virtual Try-On image
  Future<String> generateTryOn({
    required String garmentImageUrl,
    required String personImageUrl,
    String? modelName, // defaults to 'fast' if null
    String? productId,
    String? externalUserId,
    Map<String, dynamic>? metadata,
    double? version, // defaults to 1.1 if null
  }) async {
    try {
      final response = await _dio.post(
        '/vton/generate',
        data: {
          'model_name': modelName ?? 'fast',
          'inputClothesImageUrls': [garmentImageUrl],
          'inputPersonImageUrls': [personImageUrl],
          'userId': userId,
          'version': version ?? 1.1,
          if (productId != null) 'productId': productId,
          if (externalUserId != null) 'externalUserId': externalUserId,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final outputUrls = response.data['outputImageUrls'] as List;
        if (outputUrls.isNotEmpty) {
          return outputUrls.first as String;
        }
      }
      throw SnapITException('Generation failed to return output URLs');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout');
    }

    final status = error.response?.statusCode;
    final message = error.response?.data?['detail'] ?? error.message;

    switch (status) {
      case 401:
        return InvalidAPIKeyException(message);
      case 403:
        return UnauthorizedException(message);
      case 404:
        return UserNotFoundException(message);
      case 501:
        return InsufficientCreditsException(message);
      default:
        return SnapITException(message ?? 'Connection failed');
    }
  }
}
