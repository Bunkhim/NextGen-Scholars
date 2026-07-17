import 'package:get/get.dart';
import 'package:scholarship_app/services/display_settings_service.dart';

class FontSizeController extends GetxController {
  final _service = DisplaySettingsService();
  final RxDouble currentScale = 1.0.obs;

  List<Map<String, dynamic>> get options => DisplaySettingsService.textScaleOptions;

  @override
  void onInit() {
    super.onInit();
    currentScale.value = _service.currentTextScale;
  }

  int scaleToIndex(double scale) {
    for (int i = 0; i < options.length; i++) {
      if (((options[i]['scale'] as double) - scale).abs() < 0.01) return i;
    }
    return 1; // Default index
  }

  void onScaleChanged(double value) {
    final index = value.round();
    final scale = options[index]['scale'] as double;
    currentScale.value = scale;
    _service.setTextScale(scale);
  }
}
