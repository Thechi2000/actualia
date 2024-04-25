import 'package:flutter/material.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({super.key});

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  var isPlaying = false;

  @override
  Widget build(BuildContext context) {
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
          setState(() {
            isPlaying = !isPlaying;
          });
        });
  }
}
