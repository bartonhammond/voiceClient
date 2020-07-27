import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:voiceClient/constants/enums.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({this.iconData, this.text, this.badge});
  IconData iconData;
  String text;
  String badge;
}

class FABBottomAppBar extends StatefulWidget {
  const FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height = 60.0,
    this.iconSize = 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
  }) : assert(items.length == 2 || items.length == 4);

  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<TabItem> onTabSelected;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  void _updateIndex(int index) {
    widget.onTabSelected(TabItem.values[index]);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: NeumorphicTheme.currentTheme(context).variantColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText ?? '',
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    FABBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    final Color color = _selectedIndex == index ? Colors.black : Colors.white;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Stack(
              children: <Widget>[
                item.badge == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(left: 35, top: 5),
                        child: item.badge == '0'
                            ? Container()
                            : Badge(badgeContent: Text(item.badge)),
                      ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child:
                      Icon(item.iconData, color: color, size: widget.iconSize),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Text(item.text, style: TextStyle(color: color)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
