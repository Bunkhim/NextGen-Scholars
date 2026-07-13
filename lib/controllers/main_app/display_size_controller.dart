import 'package:get/get.dart';
import 'package:scholarship_app/services/display_settings_service.dart';

class DisplaySizeController extends GetxController {
  final DisplaySettingsService _service = DisplaySettingsService();

  final RxDouble currentScale = 1.0.obs;

  List<Map<String, dynamic>> get options =>
      DisplaySettingsService.displayScaleOptions;

  @override
  void onInit() {
    super.onInit();
    currentScale.value = _service.currentDisplayScale;
  }

  int scaleToIndex(double scale) {
    for (int i = 0; i < options.length; i++) {
      final optionScale = options[i]['scale'] as double;
      if ((optionScale - scale).abs() < 0.01) {
        return i;
      }
    }
    return 1;
  }

  Future<void> setScaleByIndex(int index) async {
    if (index < 0 || index >= options.length) return;
    final scale = options[index]['scale'] as double;
    await setScale(scale);
  }

  Future<void> setScale(double scale) async {
    currentScale.value = scale;
    await _service.setDisplayScale(scale);
  }

  String currentLabelKey() => _service.currentDisplayScaleLabelKey();
}
