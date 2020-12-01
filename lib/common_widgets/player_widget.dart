import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

// ignore: must_be_immutable
class PlayerWidget extends StatefulWidget {
  PlayerWidget({
    Key key,
    this.mode = PlayerMode.MEDIA_PLAYER,
    this.showSlider = true,
    this.width = 500,
    this.path = '',
    this.isLocal = false,
    this.resetPosition = false,
    this.url = '',
    this.duration,
    this.position,
  }) : super(key: key);

  final PlayerMode mode;
  final bool showSlider;
  final int width;
  final String path;
  final bool isLocal;
  final String url;
  final bool resetPosition;

  Duration duration;
  Duration position;
  Uint8List byteData;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  _PlayerWidgetState();
  AudioPlayer _audioPlayer;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        widget.showSlider
            ? Container(
                margin: EdgeInsets.all(10),
                width: widget.width.toDouble(),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue[700],
                    inactiveTrackColor: Colors.blue[100],
                    trackShape: RectangularSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbColor: Colors.cyan,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 10.0),
                  ),
                  child: Slider(
                    onChanged: (v) {
                      final position = v * widget.duration.inMilliseconds;
                      _audioPlayer
                          .seek(Duration(milliseconds: position.round()));
                    },
                    value: (widget.position != null &&
                            widget.duration != null &&
                            widget.position.inMilliseconds > 0 &&
                            widget.position.inMilliseconds <
                                widget.duration.inMilliseconds)
                        ? widget.position.inMilliseconds /
                            widget.duration.inMilliseconds
                        : 0.0,
                  ),
                ),
              )
            : Container(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.all(0),
              key: Key('play_button'),
              onPressed: _isPlaying ? null : () => play(),
              iconSize: 25.0,
              icon: Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              padding: EdgeInsets.all(0),
              key: Key('pause_button'),
              onPressed: _isPlaying ? () => _pause() : null,
              iconSize: 25.0,
              icon: Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              padding: EdgeInsets.all(0),
              key: Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? () => _stop() : null,
              iconSize: 25.0,
              icon: Icon(Icons.stop),
              color: Colors.cyan,
            ),
          ],
        ),
      ],
    );
  }

  void initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: widget.mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => widget.duration = duration);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
            forwardSkipInterval: const Duration(seconds: 30), // default is 30s
            backwardSkipInterval: const Duration(seconds: 30), // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              widget.position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        widget.position = widget.duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.stopped;
        widget.duration = Duration(seconds: 0);
        widget.position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {});

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {});
  }

  Future<int> play() async {
    try {
      final playPosition = (widget.position != null &&
              widget.duration != null &&
              widget.position.inMilliseconds > 0 &&
              widget.position.inMilliseconds < widget.duration.inMilliseconds)
          ? widget.position
          : null;
      int result;
      if (widget.isLocal == true) {
        result = await _audioPlayer.play(
          widget.path,
          isLocal: widget.isLocal,
          position: playPosition,
        );
      } else {
        result = await _audioPlayer.play(
          widget.url,
          isLocal: widget.isLocal,
          position: playPosition,
        );
      }
      if (result == 1) {
        setState(() => _playerState = PlayerState.playing);
      }
      return result;
    } catch (error) {
      print(error.toString());
      rethrow;
    }
  }

  Future<int> _pause() async {
    try {
      final result = await _audioPlayer.pause();
      if (result == 1) {
        setState(() => _playerState = PlayerState.paused);
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<int> _stop() async {
    try {
      final result = await _audioPlayer.stop();
      if (result == 1) {
        setState(() {
          _playerState = PlayerState.stopped;
          widget.position = Duration();
        });
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  void _onComplete() {
    try {
      setState(() => _playerState = PlayerState.stopped);
    } catch (error) {
      rethrow;
    }
  }
}
