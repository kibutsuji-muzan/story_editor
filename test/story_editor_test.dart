import 'package:flutter_test/flutter_test.dart';
import 'package:story_editor/story_editor.dart';

void main() {
  test('TransformData initialization', () {
    final transform = TransformData();
    expect(transform.matrix.isIdentity(), isTrue);
  });
}
