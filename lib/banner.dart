import 'dart:io' show Platform;

import 'package:MyFamilyVoice/constants/admob.dart';
import 'package:firebase_admob/firebase_admob.dart';

BannerAd createBannerAdd(List<String> keywords) {
  final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: keywords,
    contentUrl: 'https://myfamilyvoice.com',
    childDirected: false,
    testDevices: <String>['8F6E7E74-D953-4AB4-942B-4590972A5398'],
  );
  String testAdUnit;
  if (Platform.isAndroid) {
    testAdUnit = AdMob.androidAdUnitIdBanner;
  } else if (Platform.isIOS) {
    testAdUnit = AdMob.iosAdUnitIdBanner;
  }
  return BannerAd(
      targetingInfo: targetingInfo,
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print('Banner Event: $event');
      });
}
