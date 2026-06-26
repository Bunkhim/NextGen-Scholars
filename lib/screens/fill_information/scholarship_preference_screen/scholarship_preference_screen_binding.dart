part of 'scholarship_preference_screen_view.dart';

class ScholarshipPreferenceScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScholarshipPreferenceScreenViewController());
  }
}
