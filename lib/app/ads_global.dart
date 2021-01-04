class AdsGlobal {
  int currentDisplayCount = 0;
  int adDisplayFrequency = 25;

  bool showAd() {
    currentDisplayCount++;
    final bool equal = currentDisplayCount == adDisplayFrequency;
    if (equal) {
      currentDisplayCount = 0;
    }
    return equal;
  }

  bool willShowAd(int length) {
    return length + currentDisplayCount > adDisplayFrequency;
  }
}
