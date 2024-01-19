import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MusicTestComponent extends StatefulWidget {
  String url;
  MusicTestComponent({
    super.key,
    required this.url,
  });

  @override
  State<MusicTestComponent> createState() => _MusicTestComponentState();
}

class _MusicTestComponentState extends State<MusicTestComponent> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = true;
  bool _progressVisibility = false;
  bool isLoading = true;
  late File _file;

  @override
  void initState() {
    super.initState();
    loadAndSaveFile();
  }

  Future<void> loadAndSaveFile() async {
    var res = await http.get(
      Uri.parse(widget.url),
    );
    Directory tempDir = await getTemporaryDirectory();
    String filename = '${tempDir.path}/audio.mp4';
    File file = File(filename);
    await file.writeAsBytes(res.bodyBytes);
    setState(() {
      _file = file;
    });
    _loadAudio();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });

    await _trimmer.loadAudio(audioFile: _file).then((value) => _trimmerplay());

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _trimmerplay() async {
    bool _playback = await _trimmer.audioPlaybackControl(
        startValue: _startValue, endValue: _endValue);
    setState(() {
      _isPlaying = _playback;
    });
  }

  _saveAudio() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedAudio(
      startValue: _startValue,
      endValue: _endValue,
      audioFileName: DateTime.now().millisecondsSinceEpoch.toString(),
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        debugPrint('OUTPUT PATH: $outputPath');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Audio Trimmer"),
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : Center(
              child: Container(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Visibility(
                      visible: _progressVisibility,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('$_startValue , $_endValue');
                      },
                      // _progressVisibility ? null : () => _saveAudio(),
                      child: const Text("SAVE"),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TrimViewer(
                          trimmer: _trimmer,
                          viewerHeight: 50,
                          maxAudioLength: const Duration(seconds: 50),
                          viewerWidth: MediaQuery.of(context).size.width,
                          durationStyle: DurationStyle.FORMAT_MM_SS,
                          backgroundColor: Colors.white,
                          barColor: Colors.black12,
                          durationTextStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          allowAudioSelection: true,
                          editorProperties: TrimEditorProperties(
                            circleSize: 10,
                            borderPaintColor: Colors.blue,
                            borderWidth: 4,
                            borderRadius: 5,
                            circlePaintColor: Colors.blue.shade700,
                          ),
                          areaProperties:
                              TrimAreaProperties.edgeBlur(blurEdges: true),
                          onChangeStart: (value) {
                            _startValue = value;
                          },
                          onChangeEnd: (value) {
                            _endValue = value;
                          },
                          onChangePlaybackState: (value) async {
                            if (!value) {
                              await _trimmerplay();
                            }
                          },
                        ),
                      ),
                    ),
                    TextButton(
                      child: _isPlaying
                          ? Icon(
                              Icons.pause,
                              size: 80.0,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.play_arrow,
                              size: 80.0,
                              color: Theme.of(context).primaryColor,
                            ),
                      onPressed: () async {
                        bool playbackState =
                            await _trimmer.audioPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        print(playbackState);
                        setState(() => _isPlaying = playbackState);
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
