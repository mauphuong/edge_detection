import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'edge_detection_method_channel.dart';

abstract class EdgeDetectionPlatform extends PlatformInterface {
  /// Constructs a EdgeDetectionPlatform.
  EdgeDetectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static EdgeDetectionPlatform _instance = MethodChannelEdgeDetection();

  /// The default instance of [EdgeDetectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelEdgeDetection].
  static EdgeDetectionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EdgeDetectionPlatform] when
  /// they register themselves.
  static set instance(EdgeDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
