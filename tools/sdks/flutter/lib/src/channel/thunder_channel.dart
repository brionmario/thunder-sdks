import 'package:flutter/services.dart';
import '../models/iam_error.dart';

/// Method channel bridge to the native iOS and Android Thunder Platform SDKs.
/// All protocol operations (OAuth2/OIDC, token management, flow orchestration)
/// are delegated to the native SDK via this channel.
class ThunderChannel {
  static const MethodChannel _channel = MethodChannel('io.thunder/sdk');

  Future<T?> invoke<T>(String method, [Map<String, dynamic>? args]) async {
    try {
      final result = await _channel.invokeMethod<T>(method, args);
      return result;
    } on PlatformException catch (e) {
      final code = IAMErrorCode.fromString(e.code);
      throw IAMException(code, e.message ?? 'Platform error', cause: e);
    }
  }

  Future<Map<dynamic, dynamic>> invokeMap(String method, [Map<String, dynamic>? args]) async {
    try {
      final result = await _channel.invokeMethod<Map>(method, args);
      return result ?? {};
    } on PlatformException catch (e) {
      final code = IAMErrorCode.fromString(e.code);
      throw IAMException(code, e.message ?? 'Platform error', cause: e);
    }
  }

  Future<List<dynamic>> invokeList(String method, [Map<String, dynamic>? args]) async {
    try {
      final result = await _channel.invokeMethod<List>(method, args);
      return result ?? [];
    } on PlatformException catch (e) {
      final code = IAMErrorCode.fromString(e.code);
      throw IAMException(code, e.message ?? 'Platform error', cause: e);
    }
  }
}
