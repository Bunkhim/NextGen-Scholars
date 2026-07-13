import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/display_settings_service.dart';

class FontPickerController extends GetxController with GetSingleTickerProviderStateMixin {
  final _service = DisplaySettingsService();
  final RxnString selectedFont = RxnString();
  
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  List<Map<String, String>> get fonts => DisplaySettingsService.availableFonts;

  @override
  void onInit() {
    super.onInit();
    selectedFont.value = _service.currentFontFamily;
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

  void selectFont(String? family) {
    selectedFont.value = family;
    _service.setFontFamily(family);
  }
}
