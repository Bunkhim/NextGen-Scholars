import 'package:get/get.dart';
import 'package:scholarship_app/services/display_settings_service.dart';

class FontPickerController extends GetxController {
  final _service = DisplaySettingsService();
  final RxnString selectedFont = RxnString();

  List<Map<String, String>> get fonts => DisplaySettingsService.availableFonts;

  @override
  void onInit() {
    super.onInit();
    selectedFont.value = _service.currentFontFamily;
  }

  void selectFont(String? family) {
    selectedFont.value = family;
    _service.setFontFamily(family);
  }
}
