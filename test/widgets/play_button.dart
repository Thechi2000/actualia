import 'package:actualia/widgets/play_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets('testPlayButton', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const App());

    const int dummyTranscriptID = 0;

    await tester.pumpWidget(MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const PlayButton(transcriptId: dummyTranscriptID)));

    expect(find.byType(PlayButton), findsOne);
    expect(find.byType(IconButton), findsOne);
  });

  testWidgets('PlayerStateAwakening', (WidgetTester tester) async {
    const int dummyTranscriptID = -1;

    await tester.pumpWidget(MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const PlayButton(transcriptId: dummyTranscriptID)));

    final button = find.byType(PlayButton);
    final PlayButtonState state = tester.state(button);

    assert(state.playerState == PlayerState.stopped);
    await tester.tap(button);
    await tester.pump();
    assert(state.playerState == PlayerState.playing);
  });
}
