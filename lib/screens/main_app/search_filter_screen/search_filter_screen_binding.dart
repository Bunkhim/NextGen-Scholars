part of 'search_filter_screen_view.dart';

class SearchFilterScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchFilterScreenViewController());
  }
}
