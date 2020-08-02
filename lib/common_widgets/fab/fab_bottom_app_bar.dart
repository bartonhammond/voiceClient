import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/constants/enums.dart';

import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({this.iconData, this.text});
  IconData iconData;
  String text;
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
    final List<int> counts = [0, 0, 0, 0];

    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    return Query(
      options: QueryOptions(
        documentNode: gql(newMessagesCount),
        variables: <String, dynamic>{
          'email': graphQLAuth.getUser().email,
          // set cursor to null so as to start at the beginning
          // 'cursor': 10
        }, // this is the query string you just created
        pollInterval: 10,
      ),
      // Just like in apollo refetch() could be used to manually trigger a refetch
      // while fetchMore() can be used for pagination purpose
      builder: (QueryResult result, {refetch, FetchMore fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        counts[2] = result.data['newMessagesCount']['count'];

        final List<Widget> items =
            List.generate(widget.items.length, (int index) {
          return _buildTabItem(
            item: widget.items[index],
            index: index,
            onPressed: _updateIndex,
            count: counts[index],
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
      },
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
    int count,
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
              Positioned(
                top: 5,
                left: 25,
                child: Icon(item.iconData, color: color, size: widget.iconSize),
              ),
              Positioned(
                top: 30,
                left: 15,
                child: Text(item.text, style: TextStyle(color: color)),
              ),
              Positioned(
                right: 10,
                child: count == 0
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: count == 0
                            ? Container()
                            : Text(
                                '$count',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
