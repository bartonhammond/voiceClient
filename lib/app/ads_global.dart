import 'dart:math';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:flutter/material.dart';

class AdsGlobal {
  AdsGlobal(BuildContext context) {
    authServiceType = AppConfig.of(context).authServiceType;
  }
  AuthServiceType authServiceType;
  int min = 5;
  int max = 15;

  int currentDisplayCount = 0;
  int adDisplayFrequency = 5;
  Random rnd = Random();

  /// Determin if the add should show
  bool showAd() {
    if (authServiceType == AuthServiceType.mock) {
      return false;
    }
    currentDisplayCount++;

    final bool equal = currentDisplayCount == adDisplayFrequency;
    if (equal) {
      currentDisplayCount = 0;
    }
    return equal;
  }

  void randomizeFrequency() {
    adDisplayFrequency = min + rnd.nextInt(max - min);
  }
}
