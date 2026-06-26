part of 'search_result_screen_view.dart';

class SearchResultScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchResultScreenViewController());
  }
}
