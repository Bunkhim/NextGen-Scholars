import 'package:get/get.dart';
import 'package:scholarship_app/services/display_settings_service.dart';

/// GetX wrapper around the existing [DisplaySettingsService] singleton.
///
/// The service still owns persistence (SharedPreferences), the available
/// font list, and the scale-option tables — this controller only mirrors
/// its three `ValueNotifier`s as `Rx` values so widgets can use `Obx`
/// instead of `ValueListenableBuilder`.
class DisplaySettingsController extends GetxController {
  final Rx<String?> fontFamily =
      Rx<String?>(DisplaySettingsService.fontFamilyNotifier.value);
  final RxDouble textScale =
      DisplaySettingsService.textScaleNotifier.value.obs;
  final RxDouble displayScale =
      DisplaySettingsService.displayScaleNotifier.value.obs;

  @override
  void onInit() {
    super.onInit();
    DisplaySettingsService.fontFamilyNotifier.addListener(_onFontChanged);
    DisplaySettingsService.textScaleNotifier.addListener(_onTextScaleChanged);
    DisplaySettingsService.displayScaleNotifier
        .addListener(_onDisplayScaleChanged);

    // Load persisted values on startup.
    DisplaySettingsService().loadSettings();
  }

  @override
  void onClose() {
    DisplaySettingsService.fontFamilyNotifier.removeListener(_onFontChanged);
    DisplaySettingsService.textScaleNotifier
        .removeListener(_onTextScaleChanged);
    DisplaySettingsService.displayScaleNotifier
        .removeListener(_onDisplayScaleChanged);
    super.onClose();
  }

  void _onFontChanged() =>
      fontFamily.value = DisplaySettingsService.fontFamilyNotifier.value;

  void _onTextScaleChanged() =>
      textScale.value = DisplaySettingsService.textScaleNotifier.value;

  void _onDisplayScaleChanged() =>
      displayScale.value = DisplaySettingsService.displayScaleNotifier.value;

  // ── Pass-through reference data ──────────────────────────────────────────

  List<Map<String, String>> get availableFonts =>
      DisplaySettingsService.availableFonts;

  List<Map<String, dynamic>> get textScaleOptions =>
      DisplaySettingsService.textScaleOptions;

  List<Map<String, dynamic>> get displayScaleOptions =>
      DisplaySettingsService.displayScaleOptions;

  String get fontDisplayName => DisplaySettingsService().currentFontDisplayName;

  String get textScaleLabelKey =>
      DisplaySettingsService().currentTextScaleLabelKey();

  String get displayScaleLabelKey =>
      DisplaySettingsService().currentDisplayScaleLabelKey();

  // ── Setters (delegate to service, which persists + updates notifiers) ────

  Future<void> setFontFamily(String? family) async {
    await DisplaySettingsService().setFontFamily(family);
    fontFamily.value = family;
  }

  Future<void> setTextScale(double scale) async {
    await DisplaySettingsService().setTextScale(scale);
    textScale.value = scale;
  }

  Future<void> setDisplayScale(double scale) async {
    await DisplaySettingsService().setDisplayScale(scale);
    displayScale.value = scale;
  }
}