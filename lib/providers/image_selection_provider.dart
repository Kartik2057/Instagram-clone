import 'package:flutter/foundation.dart';

class ImageSelectionProvider extends ChangeNotifier {
  static  Set<String> _selectedImages = {};

  Set<String> get selectedImages => _selectedImages;
  static void setSelectedImages(){
    _selectedImages={};
  }
  static Set<String> getSelectedImages(){
    return _selectedImages;
  }

  void toggleImageSelection(String imageUrl) {
    if (_selectedImages.contains(imageUrl)) {
      _selectedImages.remove(imageUrl);
    } else {
      _selectedImages.add(imageUrl);
    }
    notifyListeners();
  }
}
