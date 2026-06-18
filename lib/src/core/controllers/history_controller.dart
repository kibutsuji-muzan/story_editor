import '../models/editor_state.dart';

class HistoryController {
  final List<EditorState> _history = [];
  int _currentIndex = -1;

  bool get canUndo => _currentIndex > 0;
  bool get canRedo => _currentIndex < _history.length - 1;

  void pushState(EditorState state) {
    // Truncate redo history when a new state is pushed
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    _history.add(state);
    _currentIndex = _history.length - 1;
  }

  EditorState? undo() {
    if (!canUndo) return null;
    _currentIndex--;
    return _history[_currentIndex];
  }

  EditorState? redo() {
    if (!canRedo) return null;
    _currentIndex++;
    return _history[_currentIndex];
  }

  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}
