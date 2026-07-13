import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/display_settings_service.dart';

class FontSizeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _service = DisplaySettingsService();
  final RxDouble currentScale = 1.0.obs;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  List<Map<String, dynamic>> get options => DisplaySettingsService.textScaleOptions;

  @override
  void onInit() {
    super.onInit();
    currentScale.value = _service.currentTextScale;
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );
    animationController.forward();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
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
