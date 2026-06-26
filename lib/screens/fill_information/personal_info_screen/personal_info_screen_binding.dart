part of 'personal_info_screen_view.dart';

class PersonalInfoScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalInfoScreenViewController());
  }
}
