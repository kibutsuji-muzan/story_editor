import 'dart:math';

class LayerUtils {
  static String generateUniqueId(String prefix) {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randVal = random.nextInt(10000);
    return '${prefix}_${timestamp}_$randVal';
  }
}
