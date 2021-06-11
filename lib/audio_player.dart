import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final mediaItem = MediaItem(
      id: "asset:///assets/song.mp3",
      album: "Adzan",
      title: "Bar",
    );
    AudioServiceBackground.setMediaItem(mediaItem);

    // Listen to state changes on the player...
    _audioPlayer.playerStateStream.listen((playerState) {
      // ... and forward them to all audio_service clients.
      AudioServiceBackground.setState(
        playing: playerState.playing,
        // Every state from the audio player gets mapped onto an audio_service state.
        processingState: {
          // ProcessingState.none: AudioProcessingState.none,
          ProcessingState.loading: AudioProcessingState.connecting,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[playerState.processingState],
        // Tell clients what buttons/controls should be enabled in the
        // current state.
        controls: [
          playerState.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
      );
    });
    // Play when ready.
    // _audioPlayer.play();
    // Start loading something (will play when ready).
    await _audioPlayer.setUrl(mediaItem.id);
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.completed);
    await _audioPlayer.stop();
    await super.onStop();
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.ready);
    await _audioPlayer.play();
    return super.onPlay();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready);
    await _audioPlayer.pause();
    return super.onPause();
  }
}

class Audio extends StatefulWidget {
  @override
  _AudioState createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<PlaybackState>(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            if (playing)
              return Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                          child: Icon(Icons.pause_circle_filled_rounded),
                          onPressed: () {
                            AudioService.pause();
                          }),
                      RaisedButton(
                          child: Icon(Icons.stop_circle_outlined),
                          onPressed: () {
                            AudioService.stop();
                          })
                    ]),
              );
            else
              return Center(
                child: RaisedButton(
                    child: Icon(Icons.play_arrow_rounded),
                    onPressed: () {
                      if (AudioService.running) {
                        AudioService.play();
                      } else {
                        AudioService.start(
                            backgroundTaskEntrypoint:
                                _backgroundTaskEntrypoint);
                        // params: {"url": url});
                      }
                    }),
              );
          }),
    );
  }
}
