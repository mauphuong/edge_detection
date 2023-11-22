import 'package:flutter_test/flutter_test.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:edge_detection/edge_detection_platform_interface.dart';
import 'package:edge_detection/edge_detection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEdgeDetectionPlatform
    with MockPlatformInterfaceMixin
    implements EdgeDetectionPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EdgeDetectionPlatform initialPlatform = EdgeDetectionPlatform.instance;

  test('$MethodChannelEdgeDetection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEdgeDetection>());
  });

  test('getPlatformVersion', () async {
    EdgeDetection edgeDetectionPlugin = EdgeDetection();
    MockEdgeDetectionPlatform fakePlatform = MockEdgeDetectionPlatform();
    EdgeDetectionPlatform.instance = fakePlatform;

    expect(await edgeDetectionPlugin.getPlatformVersion(), '42');
  });
}
