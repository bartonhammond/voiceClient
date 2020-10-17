import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class FabWithIcons extends StatefulWidget {
  const FabWithIcons({this.icons, this.onIconTapped});
  final List<IconData> icons;
  final ValueChanged<Map<String, dynamic>> onIconTapped;
  @override
  State createState() => FabWithIconsState();
}

class FabWithIconsState extends State<FabWithIcons>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.icons.length, (int index) {
        return _buildChild(context, index);
      }).toList()
        ..add(
          _buildFab(),
        ),
    );
  }

  Widget _buildChild(BuildContext context, int index) {
    return Container(
      height: 70.0,
      width: 56.0,
      alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 1.0 - index / widget.icons.length / 2.0,
              curve: Curves.easeOut),
        ),
        child: FloatingActionButton(
          mini: false,
          child: Icon(
            widget.icons[index],
          ),
          onPressed: () => _onTapped(context, index),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: Color(0xff00bcd4),
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      tooltip: Strings.incrementToolTip.i18n,
      child: Icon(Icons.add),
      elevation: 2.0,
    );
  }

  void _onTapped(BuildContext context, int index) {
    _controller.reverse();
    final Map<String, dynamic> map = <String, dynamic>{};
    map['context'] = context;
    map['index'] = index;
    widget.onIconTapped(map);
  }
}
