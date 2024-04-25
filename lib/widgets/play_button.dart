import 'dart:developer';
import 'package:logging/logging.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayButton extends StatefulWidget {
  final Uint8List source;
  const PlayButton({super.key, required this.source});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  var isPlaying = false;
  var hasStarted = false;

  @override
  Widget build(BuildContext context) {
    final AudioPlayer audioPlayer = AudioPlayer();
    return IconButton(
        icon: isPlaying
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
        onPressed: () {
          Permission perm;
          setState(() {
            isPlaying = !isPlaying;
          });
          if (isPlaying) {
            if (!hasStarted) {
              hasStarted = true;
              playAudio(
                  audioPlayer,
                  //AssetSource("audio/boom.mp3"));
                  UrlSource(
                      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"));
              //playAudio(audioPlayer, BytesSource(widget.source));
            } else {
              audioPlayer.resume();
            }
          } else {
            audioPlayer.pause();
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
