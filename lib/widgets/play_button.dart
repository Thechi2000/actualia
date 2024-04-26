import 'dart:developer';
import 'package:logging/logging.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayButton extends StatefulWidget {
  final int transcriptId;
  const PlayButton({super.key, required this.transcriptId});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  PlayerState _PlayerState = PlayerState.completed;

  @override
  Widget build(BuildContext context) {
    final AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.onPlayerComplete.listen((s) async {
      setState(() {
        _PlayerState = PlayerState.completed;
      });
      await audioPlayer.release();
    });
    audioPlayer.onPlayerStateChanged.listen((s) => debugPrint("$s"));

    return IconButton(
        icon: _PlayerState == PlayerState.playing
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
          switch (_PlayerState) {
            case PlayerState.playing:
              await audioPlayer.pause(); // FIXME: pause doesnt work properly :(
              setState(() => _PlayerState = PlayerState.paused);
              break;
            case PlayerState.paused:
              await audioPlayer.resume();
              setState(() => _PlayerState = PlayerState.playing);
              break;
            case PlayerState.completed:
            case PlayerState.stopped:
            case PlayerState.disposed:
              playAudio(audioPlayer,
                  DeviceFileSource('audio/$widget.transcriptId')); // to change
              setState(() => _PlayerState = PlayerState.playing);
              break;
          }
        });
  }

  void playAudio(AudioPlayer audioPlayer, Source source) async {
    try {
      await audioPlayer.play(source);
    } catch (e) {
      print("Error playing audio: $e");
      log("Error playing audio: $e", level: Level.WARNING.value);
    }
  }
}
