part of 'languages_screen_view.dart';

class LanguagesScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LanguagesScreenViewController());
  }
}
