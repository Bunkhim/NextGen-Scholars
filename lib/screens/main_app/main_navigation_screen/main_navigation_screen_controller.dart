part of 'main_navigation_screen_view.dart';

class MainNavigationScreenViewController extends GetxController {
  static final RxInt tabNotifier = 0.obs;

  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(tabNotifier, (val) => currentIndex.value = val);
  }
}
