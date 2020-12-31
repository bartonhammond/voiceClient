import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class ImageZoom extends StatelessWidget {
  ImageZoom({this.imageUrl});
  final String imageUrl;

  // you can handle gesture detail by yourself with key
  final GlobalKey<ExtendedImageGestureState> gestureKey =
      GlobalKey<ExtendedImageGestureState>();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(Strings.MFV.i18n),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  gestureKey.currentState.reset();
                  //you can also change zoom manual
                  //gestureKey.currentState.gestureDetails=GestureDetails();
                },
              )
            ],
          ),
          Expanded(
            child: ExtendedImage.network(
              imageUrl,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              extendedImageGestureKey: gestureKey,
              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  minScale: 0.8,
                  animationMinScale: 0.7,
                  maxScale: 4.0,
                  animationMaxScale: 4.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                  gestureDetailsIsChanged: (GestureDetails details) {
                    //print(details.totalScale);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
