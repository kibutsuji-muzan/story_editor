import 'dart:async';
import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:provider/provider.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class TimerWidget extends StatefulWidget {
  String duration;
  String? createdAt;
  bool isEditable;
  TimerWidget({
    super.key,
    this.createdAt,
    required this.duration,
    required this.isEditable,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? timer;
  String hr = '00';
  String min = '00';
  String sec = '00';
  bool endCounter = false;
  String nowtime = DateTime.now().toString();
  @override
  void initState() {
    timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => setDuration());
    super.initState();
  }

  void setDuration() {
    print(widget.createdAt);
    DateTime createdAt = DateTime.parse(widget.createdAt ?? nowtime);
    // if (!widget.isEditable) {
    //   List<String> parts = widget.createdAt!.split('T');
    //   DateTime createdAt =
    //       DateTime.parse('${parts[0]} ${parts[1].replaceAll('Z', '')}');
    // }
    DateTime storyTill = createdAt.add(const Duration(hours: 24));
    DateTime now = DateTime.now();

    Duration dur = parseDuration(duration: widget.duration);
    Duration duration = Duration(
      seconds: (dur.inSeconds - now.difference(createdAt).inSeconds),
    );
    String _dur = duration.format(DurationStyle.FORMAT_HH_MM_SS);
    if (!duration.isNegative) {
      var list = _dur.split(':');
      setState(() {
        hr = list[0];
        min = list[1];
        sec = list[2];
      });
    } else {
      setState(() => endCounter = true);
      timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.isEditable)
          ? () => showModalBottomSheet(
                context: context,
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                isScrollControlled: true,
                builder: (context) => const TimerModal(),
              )
          : () {},
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 5,
              offset: Offset(1, 0),
            )
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const Text(
            //   'some even here!!!',
            //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            // ),
            !endCounter
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _count(hr[0]),
                      _count(hr[1]),
                      const Text(
                        ':',
                        style: TextStyle(fontSize: 30),
                      ),
                      _count(min[0]),
                      _count(min[1]),
                      const Text(
                        ':',
                        style: TextStyle(fontSize: 30),
                      ),
                      _count(sec[0]),
                      _count(sec[1]),
                    ],
                  )
                : const Text(
                    'Countdown have ended',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _count(String digit) {
    return Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
        border: const Border.fromBorderSide(
          BorderSide(
            color: Color.fromRGBO(144, 144, 144, 1),
            style: BorderStyle.solid,
            width: 3,
          ),
        ),
      ),
      child: Text(digit),
    );
  }
}

class TimerModal extends StatefulWidget {
  const TimerModal({super.key});

  @override
  State<TimerModal> createState() => _TimerModalState();
}

class _TimerModalState extends State<TimerModal> {
  String hours = '00';
  String minutes = '00';
  String seconds = '00';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.5,
      minChildSize: 0.5,
      initialChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            // scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 5,
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: MediaQuery.of(context).size.width * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const Text(
                  'Select Duration...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1 / 3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: WheelChooser.custom(
                        startPosition: 0,
                        // squeeze: 1.5,
                        onValueChanged: (hr) =>
                            setState(() => hours = hr.toString()),
                        horizontal: false,
                        perspective: 0.01,
                        magnification: 1,
                        isInfinite: true,
                        children: List.generate(
                          60,
                          (index) => Text('${index.toString()} hr'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1 / 3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: WheelChooser.custom(
                        startPosition: 0,
                        // squeeze: 1.5,
                        onValueChanged: (min) =>
                            setState(() => minutes = min.toString()),
                        horizontal: false,
                        perspective: 0.01,
                        magnification: 1,
                        isInfinite: true,
                        children: List.generate(
                          60,
                          (index) => Text('${index.toString()} min'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1 / 3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: WheelChooser.custom(
                        startPosition: 0,
                        // squeeze: 1.5,
                        onValueChanged: (sec) =>
                            setState(() => seconds = sec.toString()),
                        horizontal: false,
                        perspective: 0.01,
                        magnification: 1,
                        isInfinite: true,
                        children: List.generate(
                          60,
                          (index) => Text('${index.toString()} sec'),
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<ActiveWidget>(context, listen: false)
                        .addorupdatetimer({
                      'widget': const Key('timer'),
                      'key': const Key('timer'),
                      'duration': '$hours:$minutes:$seconds',
                      'createdAt': DateTime.now().toString(),
                    });
                    Provider.of<DurationTimer>(context, listen: false)
                        .setTimer('$hours:$minutes:$seconds');
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
