class SelectionController {
  String? _selectedLayerId;

  String? get selectedLayerId => _selectedLayerId;
  bool get hasSelection => _selectedLayerId != null;

  void selectLayer(String id) {
    _selectedLayerId = id;
  }

  void deselect() {
    _selectedLayerId = null;
  }

  bool isSelected(String id) {
    return _selectedLayerId == id;
  }
}
