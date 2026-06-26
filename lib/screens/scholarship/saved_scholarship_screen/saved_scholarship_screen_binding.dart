part of 'saved_scholarship_screen_view.dart';

class SavedScholarshipScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SavedScholarshipScreenViewController());
  }
}
