import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'edge_detection_platform_interface.dart';

/// An implementation of [EdgeDetectionPlatform] that uses method channels.
class MethodChannelEdgeDetection extends EdgeDetectionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('edge_detection');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
