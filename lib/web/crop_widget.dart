import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/web/centered_slider_track_shape.dart';
import 'package:flutter/material.dart';
import 'package:crop/crop.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class CropWidget extends StatefulWidget {
  const CropWidget({
    @required this.imageBytes,
    @required this.onCropped,
  });
  final Uint8List imageBytes;
  final ValueChanged<ByteData> onCropped;
  @override
  _CropWidgetPageState createState() => _CropWidgetPageState();
}

class _CropWidgetPageState extends State<CropWidget> {
  final controller = CropController(aspectRatio: 1000 / 667.0);
  double _rotation = 0;
  BoxShape shape = BoxShape.rectangle;

  Future<void> _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cropped = await controller.crop(pixelRatio: pixelRatio);

    final ByteData byteData =
        await cropped.toByteData(format: ui.ImageByteFormat.png);
    widget.onCropped(byteData);
    Navigator.of(context).pop();

    return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.MFV.i18n),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: _cropImage,
            tooltip: 'Crop',
            icon: Icon(Icons.crop),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(8),
              child: Crop(
                onChanged: (decomposition) {

                },
                controller: controller,
                shape: shape,
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.cover,
                ),
                /* It's very important to set `fit: BoxFit.cover`.
                   Do NOT remove this line.
                   There are a lot of issues on github repo by people who remove this line and their image is not shown correctly.
                */
                foreground: IgnorePointer(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Foreground Object',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                helper: shape == BoxShape.rectangle
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: () {
                  controller.rotation = 0;
                  controller.scale = 1;
                  controller.offset = Offset.zero;
                  setState(() {
                    _rotation = 0;
                  });
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme.copyWith(
                    trackShape: CenteredRectangularSliderTrackShape(),
                  ),
                  child: Slider(
                    divisions: 360,
                    value: _rotation,
                    min: -180,
                    max: 180,
                    label: '$_rotation°',
                    onChanged: (n) {
                      setState(() {
                        _rotation = n.roundToDouble();
                        controller.rotation = _rotation;
                      });
                    },
                  ),
                ),
              ),
              PopupMenuButton<BoxShape>(
                icon: Icon(Icons.crop_free),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Box'),
                    value: BoxShape.rectangle,
                  ),
                  PopupMenuItem(
                    child: Text('Oval'),
                    value: BoxShape.circle,
                  ),
                ],
                tooltip: 'Crop Shape',
                onSelected: (x) {
                  setState(() {
                    shape = x;
                  });
                },
              ),
              PopupMenuButton<double>(
                icon: Icon(Icons.aspect_ratio),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Original'),
                    value: 1000 / 667.0,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text('16:9'),
                    value: 16.0 / 9.0,
                  ),
                  PopupMenuItem(
                    child: Text('4:3'),
                    value: 4.0 / 3.0,
                  ),
                  PopupMenuItem(
                    child: Text('3:2'),
                    value: 3.0 / 2.0,
                  ),
                  PopupMenuItem(
                    child: Text('1:1'),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text('2:3'),
                    value: 2.0 / 3.0,
                  ),
                  PopupMenuItem(
                    child: Text('3:4'),
                    value: 3.0 / 4.0,
                  ),
                  PopupMenuItem(
                    child: Text('9:16'),
                    value: 9.0 / 16.0,
                  ),
                ],
                tooltip: 'Aspect Ratio',
                onSelected: (x) {
                  controller.aspectRatio = x;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
