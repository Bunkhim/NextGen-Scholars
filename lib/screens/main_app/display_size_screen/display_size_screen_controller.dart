part of 'display_size_screen_view.dart';

class DisplaySizeScreenViewController extends GetxController {
  final currentScale = DisplaySettingsService().currentDisplayScale.obs;
  final _service = DisplaySettingsService();

  int scaleToIndex(double scale) {
    final options = DisplaySettingsService.displayScaleOptions;
    for (int i = 0; i < options.length; i++) {
      if (((options[i]['scale'] as double) - scale).abs() < 0.01) return i;
    }
    return 1;
  }

  void onScaleChanged(double value) {
    final index = value.round();
    final scale =
        DisplaySettingsService.displayScaleOptions[index]['scale'] as double;
    currentScale.value = scale;
    _service.setDisplayScale(scale);
  }
}
