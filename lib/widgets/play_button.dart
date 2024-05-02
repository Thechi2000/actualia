import 'dart:developer';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

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
    audioPlayer.onLog.listen(
      (String message) => debugPrint("AudioPlayer log: $message"),
      onError: (Object e, [StackTrace? stackTrace]) =>
          debugPrint("AudioPlayer error: $e, trace  : $stackTrace"),
    );
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
              //TODO: Fix pause
              try {
                await audioPlayer.pause();
              } catch (e) {
                log("Error pausing audio: $e", level: Level.WARNING.value);
                debugPrint("Error pausing audio: $e");
              }

              setState(() => _playerState = PlayerState.paused);
              debugPrint("Player state: $_playerState");
              break;
            case PlayerState.paused:
              await audioPlayer.resume();
              setState(() => _playerState = PlayerState.playing);
              break;
            case PlayerState.completed:
            case PlayerState.stopped:
            case PlayerState.disposed:
              Source? source = await getAudioSource(widget.transcriptId);
              if (source != null) {
                await playAudio(audioPlayer, source);
                setState(() => _playerState = PlayerState.playing);
                break;
              }
          }
        });
  }

  Future<void> playAudio(AudioPlayer audioPlayer, Source source) async {
    try {
      await audioPlayer.play(source);
    } catch (e) {
      log("Error playing audio: $e", level: Level.WARNING.value);
    }
  }

  Future<DeviceFileSource?> getAudioSource(int transcriptId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/audios/$transcriptId.mp3';

    final file = File(filePath);
    if (await file.exists()) {
      return DeviceFileSource(filePath);
    } else {
      log("Can't find audio file at $filePath", level: Level.WARNING.value);
      return null;
    }
  }
}
