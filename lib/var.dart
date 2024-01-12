import 'package:flutter/material.dart';
import 'package:flutter_edit_story/widgets/MusicWidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_edit_story/widgets/PollsWidget.dart';

enum grp { Yes, No }

chooseWidget(Widget item) {
  switch (item) {
    case PollsWidget():
      return PollsWidget(key: UniqueKey());
    case SvgPicture():
      return SvgPicture.asset(
        key: UniqueKey(),
        'assets/sticker.svg',
        width: 100,
      );
    default:
      return new Text('hello');
  }
}

List allWidgetsList = [
  PollsWidget(),
  SvgPicture.asset(
    'assets/sticker.svg',
    width: 100,
  ),
];
