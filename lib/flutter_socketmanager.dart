
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSocketmanager {
  static const MethodChannel _channel = MethodChannel('flutter_socketmanager');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
