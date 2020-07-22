import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  const PlayerWidget(
      {Key key, @required this.url, this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  final String url;
  final PlayerMode mode;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  _PlayerWidgetState(this.url, this.mode);
  String url;
  PlayerMode mode;

  AudioPlayer _audioPlayer;

  Duration _duration;
  Duration _position;

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
    print('StaggeredGridTileStory initState start');
    initAudioPlayer();
    print('StaggeredGridTileStory initState finished');
  }

  @override
  void dispose() {
    print('StaggeredGridTileStory dispose start');
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
    print('StaggeredGridTileStory dispose finished');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SliderTheme(
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
              final position = v * _duration.inMilliseconds;
              _audioPlayer.seek(Duration(milliseconds: position.round()));
            },
            value: (_position != null &&
                    _duration != null &&
                    _position.inMilliseconds > 0 &&
                    _position.inMilliseconds < _duration.inMilliseconds)
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.all(0),
              key: Key('play_button'),
              onPressed: _isPlaying ? null : () => _play(),
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
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30), // default is 30s
            backwardSkipInterval: const Duration(seconds: 30), // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('playerWidget audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {});

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {});
  }

  Future<int> _play() async {
    try {
      print('PlaywerWidget play start');
      final playPosition = (_position != null &&
              _duration != null &&
              _position.inMilliseconds > 0 &&
              _position.inMilliseconds < _duration.inMilliseconds)
          ? _position
          : null;
      final result =
          await _audioPlayer.play(url, isLocal: false, position: playPosition);
      if (result == 1) {
        setState(() => _playerState = PlayerState.playing);
      }

      // default playback rate is 1.0
      // this should be called after _audioPlayer.play() or _audioPlayer.resume()
      // this can also be called everytime the user wants to change playback rate in the UI
      //_audioPlayer.setPlaybackRate(playbackRate: 1.0);
      print('PlaywerWidget play finished');
      return result;
    } catch (error) {
      print(error.toString());
      rethrow;
    }
  }

  Future<int> _pause() async {
    try {
      print('PlaywerWidget pause start');
      final result = await _audioPlayer.pause();
      if (result == 1) {
        setState(() => _playerState = PlayerState.paused);
      }
      print('PlaywerWidget pause finished');
      return result;
    } catch (error) {
      print('PlayerWidget pause: $error.toString()');
      rethrow;
    }
  }

  Future<int> _stop() async {
    try {
      print('PlayerWidget stop start');
      final result = await _audioPlayer.stop();
      if (result == 1) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration();
        });
      }
      print('PlaywerWidget stop finished');
      return result;
    } catch (error) {
      print('PlayerWidget stop: $error.toString()');
      rethrow;
    }
  }

  void _onComplete() {
    try {
      print('PlaywerWidget onComplete start');
      setState(() => _playerState = PlayerState.stopped);
      print('PlaywerWidget onComplete finished');
    } catch (error) {
      print('PlayerWidget onComplete: $error.toString()');
      rethrow;
    }
  }
}
