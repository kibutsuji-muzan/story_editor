import 'dart:io';
import 'dart:typed_data';

enum MediaType { image, video }

abstract class MediaSource {
  const MediaSource({required this.type});
  final MediaType type;
}

class FileMediaSource extends MediaSource {
  final File file;
  const FileMediaSource(this.file, {required super.type});
}

class MemoryMediaSource extends MediaSource {
  final Uint8List bytes;
  const MemoryMediaSource(this.bytes, {required super.type});
}

class NetworkMediaSource extends MediaSource {
  final String url;
  const NetworkMediaSource(this.url, {required super.type});
}

class AssetMediaSource extends MediaSource {
  final String path;
  const AssetMediaSource(this.path, {required super.type});
}
