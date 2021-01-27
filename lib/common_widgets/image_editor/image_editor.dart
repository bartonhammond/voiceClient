import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:MyFamilyVoice/common_widgets/image_editor/common_widget.dart';
import 'package:MyFamilyVoice/common_widgets/image_editor/crop_editor_helper.dart';
import 'package:MyFamilyVoice/common_widgets/image_editor/screen_util.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ImageEditor extends StatefulWidget {
  const ImageEditor({
    @required this.bytes,
    @required this.onImageSelected,
  });
  final Uint8List bytes;
  final Function(ByteData) onImageSelected;

  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<ExtendedImageCropLayerCornerPainter>>
      popupMenuKey =
      GlobalKey<PopupMenuButtonState<ExtendedImageCropLayerCornerPainter>>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];
  AspectRatioItem _aspectRatio;
  bool _cropping = false;

  ExtendedImageCropLayerCornerPainter _cornerPainter;

  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    _cornerPainter = const ExtendedImageCropLayerPainterNinetyDegreesCorner();
    eventBus.fire(HideStoryBanner());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    double fontSize = 10.0;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        print('imageEditor desktop');
        fontSize = 24.0;
        break;
      case DeviceScreenType.mobile:
        print('imageEditor mobile');
        fontSize = 14.0;
        break;
      case DeviceScreenType.watch:
        print('imageEditor watch');
        fontSize = 10.0;
        break;
      default:
        fontSize = 10.0;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00bcd4),
        title: Text(Strings.MFV.i18n),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              if (kIsWeb) {
                _cropImage(false);
              } else {
                Navigator.of(context).pop();
                _cropImage(true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          key: Key('imageEditorScroll'),
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: ExtendedImage.memory(
                    widget.bytes,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    enableLoadState: true,
                    extendedImageEditorKey: editorKey,
                    initEditorConfigHandler: (ExtendedImageState state) {
                      return EditorConfig(
                          maxScale: 8.0,
                          cropRectPadding: const EdgeInsets.all(20.0),
                          hitTestSize: 20.0,
                          cornerPainter: _cornerPainter,
                          initCropRectType: InitCropRectType.imageRect,
                          cropAspectRatio: _aspectRatio.value);
                    },
                  )),
                ]),
          )),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xff00bcd4),
        shape: const CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButtonWithIcon(
                icon: const Icon(Icons.crop, color: Colors.white),
                label: Text(
                  'Crop',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
                onPressed: () {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: <Widget>[
                            const Expanded(
                              child: SizedBox(),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(200.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(20.0),
                                itemBuilder: (_, int index) {
                                  final AspectRatioItem item =
                                      _aspectRatios[index];
                                  return GestureDetector(
                                    child: AspectRatioWidget(
                                      aspectRatio: item.value,
                                      aspectRatioS: item.text,
                                      isSelected: item == _aspectRatio,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _aspectRatio = item;
                                      });
                                    },
                                  );
                                },
                                itemCount: _aspectRatios.length,
                              ),
                            ),
                          ],
                        );
                      });
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.flip, color: Colors.white),
                label: Text(
                  'Flip',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
                onPressed: () {
                  editorKey.currentState.flip();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_left, color: Colors.white),
                label: Text(
                  'Turn',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
                onPressed: () {
                  editorKey.currentState.rotate(right: false);
                },
              ),
              FlatButtonWithIcon(
                icon:
                    const Icon(Icons.rounded_corner_sharp, color: Colors.white),
                label: PopupMenuButton<ExtendedImageCropLayerCornerPainter>(
                  key: popupMenuKey,
                  enabled: false,
                  offset: const Offset(100, -300),
                  child: Text(
                    'Corner',
                    style: TextStyle(fontSize: fontSize, color: Colors.white),
                  ),
                  initialValue: _cornerPainter,
                  itemBuilder: (BuildContext context) {
                    return <
                        PopupMenuEntry<ExtendedImageCropLayerCornerPainter>>[
                      PopupMenuItem<ExtendedImageCropLayerCornerPainter>(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.rounded_corner_sharp,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'NinetyDegrees',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ],
                        ),
                        value:
                            const ExtendedImageCropLayerPainterNinetyDegreesCorner(),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<ExtendedImageCropLayerCornerPainter>(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.circle,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Circle',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ],
                        ),
                        value:
                            const ExtendedImageCropLayerPainterCircleCorner(),
                      ),
                    ];
                  },
                  onSelected: (ExtendedImageCropLayerCornerPainter value) {
                    if (_cornerPainter != value) {
                      setState(() {
                        _cornerPainter = value;
                      });
                    }
                  },
                ),
                onPressed: () {
                  popupMenuKey.currentState.showButtonMenu();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(
                  Icons.restore,
                  color: Colors.white,
                ),
                label: Text(
                  'Reset',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
                onPressed: () {
                  editorKey.currentState.reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage(bool useNative) async {
    if (_cropping) {
      return;
    }
    String msg = '';
    try {
      _cropping = true;

      //await showBusyingDialog();

      Uint8List fileData;

      /// native library
      if (useNative) {
        fileData = Uint8List.fromList(await cropImageDataWithNativeLibrary(
            state: editorKey.currentState));
      } else {
        ///delay due to cropImageDataWithDartLibrary is time consuming on main thread
        ///it will block showBusyingDialog
        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        //await Future.delayed(Duration(milliseconds: 200));

        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        fileData = Uint8List.fromList(
            await cropImageDataWithDartLibrary(state: editorKey.currentState));
      }
      widget.onImageSelected(ByteData.view(fileData.buffer));
    } catch (e, stack) {
      msg = 'save failed: $e\n $stack';
      print(msg);
    }
    _cropping = false;
  }
}
