part of 'scholarship_match_screen_view.dart';

class ScholarshipMatchScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScholarshipMatchScreenViewController());
  }
}
