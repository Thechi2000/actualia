import 'dart:developer';
import 'package:logging/logging.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayButton extends StatefulWidget {
  final int transcriptId;
  const PlayButton({super.key, required this.transcriptId});

  @override
  State<PlayButton> createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> {
  late PlayerState _playerState;
  @override
  void initState() {
    super.initState();
    _playerState = PlayerState.stopped;
  }

  PlayerState get playerState {
    return _playerState;
  }

  @override
  Widget build(BuildContext context) {
    final AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.onPlayerComplete.listen((s) async {
      setState(() {
        _playerState = PlayerState.completed;
      });
      await audioPlayer.release();
    });
    audioPlayer.onPlayerStateChanged
        .listen((s) => log("$s", level: Level.INFO.value));

    return IconButton(
        icon: _playerState == PlayerState.playing
            ? const Icon(
                Icons.pause_circle_outline,
                size: 40.0,
                color: Color.fromARGB(255, 68, 159, 166),
              )
            : const Icon(
                Icons.play_circle_outline,
                size: 40.0,
                color: Color.fromARGB(255, 68, 159, 166),
              ),
        onPressed: () async {
          switch (_playerState) {
            case PlayerState.playing:
              await audioPlayer.pause(); // FIXME: pause doesnt work properly :(
              setState(() => _playerState = PlayerState.paused);
              break;
            case PlayerState.paused:
              await audioPlayer.resume();
              setState(() => _playerState = PlayerState.playing);
              break;
            case PlayerState.completed:
            case PlayerState.stopped:
            case PlayerState.disposed:
              playAudio(
                  audioPlayer,
                  DeviceFileSource(
                      '/data/user/0/ch.epfl.swent.actualia/app_flutter/audios/$widget.transcriptId'));
              setState(() => _playerState = PlayerState.playing);
              break;
          }
        });
  }

  void playAudio(AudioPlayer audioPlayer, Source source) async {
    try {
      await audioPlayer.play(source);
    } catch (e) {
      log("Error playing audio: $e", level: Level.WARNING.value);
    }
  }
}
