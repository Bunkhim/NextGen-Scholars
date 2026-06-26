part of 'filter_result_screen_view.dart';

class FilterResultScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FilterResultScreenViewController());
  }
}
