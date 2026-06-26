part of 'help_support_screen_view.dart';

class HelpSupportScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HelpSupportScreenViewController());
  }
}
