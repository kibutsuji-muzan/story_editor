import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MusicTestComponent extends StatefulWidget {
  const MusicTestComponent({super.key});

  @override
  State<MusicTestComponent> createState() => _MusicTestComponentState();
}

class _MusicTestComponentState extends State<MusicTestComponent> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool isLoading = true;
  String _name = 'audio.mp3';
  late File _file;

  @override
  void initState() {
    super.initState();
    loadAndSaveFile();
  }

  Future<void> loadAndSaveFile() async {
    // Load the file from assets as a byte stream
    ByteData data = await rootBundle.load('assets/$_name');
    List<int> bytes = data.buffer.asUint8List();

    // Get the app's temporary directory
    Directory tempDir = await getTemporaryDirectory();

    // Create a temporary file
    File tempFile = File('${tempDir.path}/$_name');

    // Write the byte stream to the temporary file
    await tempFile.writeAsBytes(bytes);

    setState(() {
      _file = tempFile;
    });

    _loadAudio();
    // Now, you can use tempFile to access the file on the device's file system
    print('File saved to: ${tempFile}');
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });
    await _trimmer.loadAudio(audioFile: _file);
    setState(() {
      isLoading = false;
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
                      onPressed:
                          _progressVisibility ? null : () => _saveAudio(),
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
                          onChangeStart: (value) => _startValue = value,
                          onChangeEnd: (value) => _endValue = value,
                          onChangePlaybackState: (value) {
                            if (mounted) {
                              setState(() => _isPlaying = value);
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
