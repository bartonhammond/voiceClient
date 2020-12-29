import 'dart:async';

import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/services/queries_service.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:web_socket_channel/io.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({this.enabled, this.iconData, this.text});
  bool enabled;
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
    this.selectedIndex,
  }) : assert(items.length == 2 || items.length == 4);

  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;
  final int selectedIndex;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar>
    with WidgetsBindingObserver {
  IOWebSocketChannel channel;
  int _selectedIndex = 0;
  int _messageCount = 0;
  AppLifecycleState currentLifeCycle;
  GraphQLAuth graphQLAuth;

  void _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
    return;
  }

  Future<void> wserror(dynamic err) async {
    print('fab wserror ${err.toString()}');
    await reconnect();
    return;
  }

  Future<void> reconnect() async {
    print('fab reconnect start');
    if (graphQLAuth == null) {
      print('fab reconnect graphQLAuth == null');
      graphQLAuth = locator<GraphQLAuth>();
    }
    print('fab reconnect graphQLAuth != null');
    if (channel != null) {
      // add in a reconnect delay
      await Future<dynamic>.delayed(Duration(seconds: 4));
    }

    print(DateTime.now().toString() + ' Starting connection attempt...');
    channel = IOWebSocketChannel.connect(AppConfig.of(context).websocket);
    channel.sink.add(graphQLAuth.getUserMap()['email']);
    print(DateTime.now().toString() + ' Connection attempt completed.');

    channel.stream.listen(
      (dynamic data) => processMessage(),
      onDone: reconnect,
      onError: wserror,
      cancelOnError: true,
    );
  }

  void processMessage() {
    if (currentLifeCycle == AppLifecycleState.detached ||
        currentLifeCycle == AppLifecycleState.inactive ||
        currentLifeCycle == AppLifecycleState.paused) {
      _messageCount++;
    } else {
      if (mounted) {
        setState(() {
          _messageCount++;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    reconnect();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.selectedIndex;
    eventBus.on<MessagesEvent>().listen((event) {
      setState(() {
        _messageCount = event.empty ? 0 : 1;
      });
    });

    eventBus.on<GetUserMessagesEvent>().listen((event) async {
      await _getUserMessages();
    });

    Future.delayed(const Duration(milliseconds: 500), () async {
      await _getUserMessages();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    channel.sink.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 500), () {
          _getUserMessages();
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _getUserMessages() async {
    final QueryResult queryResult = await getUserMessages(
        GraphQLProvider.of(context).value,
        graphQLAuth.getUserMap()['email'],
        DateTime.now().toIso8601String());

    if (queryResult.hasException) {
      logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'fab_bottom_app_bar',
          shortMessage: queryResult.exception.toString(),
          stackTrace: StackTrace.current.toString());
      throw queryResult.exception;
    }

    setState(() {
      _messageCount = queryResult.data['userMessages'].length;
    });
  }

  @override
  Widget build(BuildContext context) {
    graphQLAuth = locator<GraphQLAuth>();
    final List<Widget> items = List.generate(widget.items.length, (int index) {
      Color iconColor;
      if (index == 2 && _messageCount > 0) {
        iconColor = Colors.red;
      }
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: widget.items[index].enabled ? _updateIndex : null,
        iconColor: widget.items[index].enabled ? iconColor : Colors.grey,
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
      color: widget.backgroundColor,
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
    Color iconColor,
  }) {
    final Color color =
        _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => item.enabled ? onPressed(index) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  item.iconData,
                  color: iconColor == null ? color : iconColor,
                  size: widget.iconSize,
                ),
                Text(
                  item.text,
                  key: Key(item.text),
                  style: TextStyle(color: color),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
