import 'dart:io';

import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

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

  Duration _startValue = Duration(milliseconds: 0);
  Duration _endValue = Duration(milliseconds: 0);

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
      startValue: _startValue.inMilliseconds.toDouble(),
      endValue: _endValue.inMilliseconds.toDouble(),
    );
    setState(() {
      _isPlaying = _playback;
    });
  }

  _saveAudio() async {
    try {
      print(_trimmer.currentAudioFile?.path);
      print(
          '${_startValue.format(DurationStyle.FORMAT_HH_MM_SS)} , ${_endValue.format(DurationStyle.FORMAT_HH_MM_SS_MS)}');

      var outPath =
          '/data/user/0/com.example.flutter_edit_story/cache/output2.mp4';
      var cmd =
          "-y -i ${_trimmer.currentAudioFile?.path} -vn -ss 0${_startValue} -to 0${_endValue} -ar 16k -ac 2 -b:a 96k -acodec copy $outPath";
      // var cmd =
      //     "-y -i ${_trimmer.currentAudioFile?.path} -vn -ss 00:00:00 -to 00:00:50 -ar 16k -ac 2 -b:a 96k -acodec copy $outPath";
      print(cmd);

      FFmpegKit.executeAsync(cmd, (session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          print('success');
        } else if (ReturnCode.isCancel(returnCode)) {
          print('cancle');
          // CANCEL
        } else {
          print('error');
          // ERROR
        }
        print("returnCode $returnCode");
      });
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _trimmer.audioPlayer!.dispose();
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
                        _saveAudio();
                        print('$_startValue , $_endValue');
                      },
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
                            _startValue = Duration(milliseconds: value.toInt());
                          },
                          onChangeEnd: (value) {
                            _endValue = Duration(milliseconds: value.toInt());
                          },
                          onChangePlaybackState: (value) async {
                            if (!value) {
                              await _trimmerplay();
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton.filled(
                      icon: Icon(
                        Icons.play_arrow,
                        size: 80.0,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        _trimmer.audioPlayer!.dispose();
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
