import 'dart:math';
import 'package:flutter/foundation.dart';

class AdsGlobal {
  int min = 5;
  int max = 15;

  int currentDisplayCount = 0;
  int adDisplayFrequency = 5;
  int currentPosition = -1;
  Random rnd = Random();

  /// Determin if the add should show
  bool showAd() {
    currentDisplayCount++;

    final bool equal = currentDisplayCount == adDisplayFrequency;
    if (equal) {
      currentDisplayCount = 0;
    }
    return equal;
  }

  ///Will the next amount of stories trigger a display of ad?
  ///return 0 - it won't happen
  ///any other number, it's the number of times it will happen
  int willShowAd(int length) {
    //change it
    adDisplayFrequency = min + rnd.nextInt(max - min);
    currentPosition = -1;
    return length ~/ adDisplayFrequency;
  }

  ///Track the story index separate from the displayCount
  ///so that we don't skip a story
  int storyCount({@required bool increment}) {
    if (!increment) {
      return currentPosition;
    }
    currentPosition++;
    return currentPosition;
  }
}
