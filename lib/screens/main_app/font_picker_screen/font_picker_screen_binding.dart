part of 'font_picker_screen_view.dart';

class FontPickerScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FontPickerScreenViewController());
  }
}
