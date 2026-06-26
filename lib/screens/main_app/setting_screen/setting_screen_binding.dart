part of 'setting_screen_view.dart';

class SettingScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingScreenViewController());
  }
}
