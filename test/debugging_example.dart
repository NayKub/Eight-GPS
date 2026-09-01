import 'package:flutter/foundation.dart';

void main() {
  debugPrint('This is a simple debug message');

  String longText = 'This is a very long string that might get truncated by standard print().' * 10;
  debugPrint(longText);

  debugPrint('Long text with wrapWidth:', wrapWidth: 50);
  debugPrint(longText, wrapWidth: 50);

  if(kDebugMode) {
    debugPrint('This message will only appear in debug mode.');
  }
}