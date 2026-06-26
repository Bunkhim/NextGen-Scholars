part of 'scholarship_detail_screen_view.dart';

class ScholarshipDetailScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScholarshipDetailScreenViewController());
  }
}
