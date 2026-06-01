import '../controllers/history_controller.dart';
import '../models/editor_state.dart';

class HistoryService {
  final HistoryController _controller = HistoryController();

  void record(EditorState state) {
    _controller.pushState(state);
  }

  EditorState? undo() => _controller.undo();
  EditorState? redo() => _controller.redo();
}
