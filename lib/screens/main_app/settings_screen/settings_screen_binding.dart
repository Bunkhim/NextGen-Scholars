part of 'settings_screen_view.dart';

class SettingsScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsScreenViewController());
  }
}
