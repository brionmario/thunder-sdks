import 'package:flutter/foundation.dart';

class AssertionSession {
  AssertionSession._();

  static final ValueNotifier<String?> assertion = ValueNotifier<String?>(null);

  static bool get isSignedIn => (assertion.value?.isNotEmpty ?? false);

  static void setAssertion(String token) {
    assertion.value = token;
  }

  static void clear() {
    assertion.value = null;
  }
}