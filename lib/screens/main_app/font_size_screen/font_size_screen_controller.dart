part of 'font_size_screen_view.dart';

class FontSizeScreenViewController extends GetxController {
  final service = DisplaySettingsService();
  final currentScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    currentScale.value = service.currentTextScale;
  }

  int scaleToIndex(double scale) {
    final options = DisplaySettingsService.textScaleOptions;
    for (int i = 0; i < options.length; i++) {
      if (((options[i]['scale'] as double) - scale).abs() < 0.01) return i;
    }
    return 1;
  }

  void onScaleChanged(double value) {
    final index = value.round();
    final scale =
        DisplaySettingsService.textScaleOptions[index]['scale'] as double;
    currentScale.value = scale;
    service.setTextScale(scale);
  }
}
