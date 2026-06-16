import 'package:flutter/widgets.dart';
import 'package:story_editor/src/core/models/media_source.dart';
import '../models/editor_layer.dart';
import '../models/editor_state.dart';
import '../models/config.dart';
import 'history_controller.dart';
import 'selection_controller.dart';

class StoryEditorController extends ChangeNotifier {
  final HistoryController _history = HistoryController();
  final SelectionController _selection = SelectionController();
  EditorState _state;

  StoryEditorController({EditorState? initialState})
    : _state = initialState ?? const EditorState() {
    _history.pushState(_state);
  }

  EditorState get state => _state;
  List<EditorLayer> get layers => _state.layers;
  String? get selectedLayerId => _selection.selectedLayerId;
  bool get hasSelection => _selection.hasSelection;
  HistoryController get history => _history;
  EditorLayer? get selectedLayer {
    if (_selection.hasSelection) {
      return _state.layers.firstWhere(
        (l) => l.id == _selection.selectedLayerId,
      );
    }
    return null;
  }

  bool get canAddLayer =>
      _state.layers.length < StoryEditorConfig.instance.maxLayersCount;

  void addLayer(EditorLayer layer) {
    if (!canAddLayer) return;
    final updatedLayers = List<EditorLayer>.from(_state.layers)..add(layer);
    _updateState(_state.copyWith(layers: updatedLayers));
    _selection.selectLayer(layer.id);
    notifyListeners();
  }

  void addLayerWithoutHistory(EditorLayer layer) {
    if (!canAddLayer) return;
    final updatedLayers = List<EditorLayer>.from(_state.layers)..add(layer);
    _state = _state.copyWith(layers: updatedLayers);
    _selection.selectLayer(layer.id);
    notifyListeners();
  }

  void updateLayer(EditorLayer layer) {
    final updatedLayers = _state.layers.map((l) {
      return l.id == layer.id ? layer : l;
    }).toList();
    _updateState(_state.copyWith(layers: updatedLayers));
    notifyListeners();
  }

  void updateLayerWithoutHistory(EditorLayer layer) {
    final updatedLayers = _state.layers.map((l) {
      return l.id == layer.id ? layer : l;
    }).toList();
    _state = _state.copyWith(layers: updatedLayers);
    notifyListeners();
  }

  void removeLayer(String id) {
    final updatedLayers = _state.layers.where((l) => l.id != id).toList();
    if (_selection.selectedLayerId == id) {
      _selection.deselect();
    }
    _updateState(_state.copyWith(layers: updatedLayers));
    notifyListeners();
  }

  void updateLayerTransform(String id, Matrix4 matrix) {
    final updatedLayers = _state.layers.map((l) {
      if (l.id == id) {
        return l.copyWith(transform: l.transform.copyWith(matrix: matrix));
      }
      return l;
    }).toList();
    _state = _state.copyWith(layers: updatedLayers);
    // Note: Do not push to history stack on every tiny drag gesture tick to prevent clogging,
    // only trigger state update to let canvas redraw. Call notifyListeners.
    notifyListeners();
  }

  void commitTransformHistory() {
    _history.pushState(_state);
  }

  void selectLayer(String id) {
    if (_selection.selectedLayerId == id) return;
    _selection.selectLayer(id);
    notifyListeners();
  }

  void deselect() {
    _selection.deselect();
    notifyListeners();
  }

  void setTaggedProduct(int productId) {
    _updateState(_state.copyWith(taggedProductId: productId));
    notifyListeners();
  }

  void setBackground(MediaSource source) {
    _updateState(_state.copyWith(background: source));
    notifyListeners();
  }

  void loadState(EditorState state) {
    _history.clear();
    _selection.deselect();
    _state = state;
    _history.pushState(_state);
    notifyListeners();
  }

  void undo() {
    final previousState = _history.undo();
    if (previousState != null) {
      _state = previousState;
      _selection.deselect();
      notifyListeners();
    }
  }

  void redo() {
    final nextState = _history.redo();
    if (nextState != null) {
      _state = nextState;
      _selection.deselect();
      notifyListeners();
    }
  }

  void _updateState(EditorState newState) {
    _state = newState;
    _history.pushState(_state);
  }
}
