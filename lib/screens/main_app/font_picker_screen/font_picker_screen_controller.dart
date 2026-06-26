part of 'font_picker_screen_view.dart';

class FontPickerScreenViewController extends GetxController {
  final service = DisplaySettingsService();
  final selectedFont = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    selectedFont.value = service.currentFontFamily;
  }

  void selectFont(String? family) {
    selectedFont.value = family;
    service.setFontFamily(family);
  }

  TextStyle getFontStyle(String family, {double fontSize = 16}) {
    if (family.isEmpty) {
      return TextStyle(fontSize: fontSize);
    }
    try {
      return GoogleFonts.getFont(family, fontSize: fontSize);
    } catch (_) {
      return TextStyle(fontSize: fontSize, fontFamily: family);
    }
  }
}
