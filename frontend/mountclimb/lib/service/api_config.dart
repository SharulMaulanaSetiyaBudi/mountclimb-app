import 'package:flutter/foundation.dart';

class ApiConfig {
  // Chrome/Web & Windows  -> 127.0.0.1
  // Android Emulator      -> 10.0.2.2 (alias ke localhost komputer)
  // HP asli               -> ganti dengan IP LAN komputer, mis. http://192.168.1.10:8000/api
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
