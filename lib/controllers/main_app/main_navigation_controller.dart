import 'package:get/get.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // MainNavigationScreen.tabNotifier stays a static ValueNotifier (not moved
    // into GetX) because other embedded tab screens may set its value
    // directly (e.g. MainNavigationScreen.tabNotifier.value = 3) to switch tabs
    // remotely without needing a reference to this controller.
    MainNavigationScreen.tabNotifier.addListener(_onTabNotifierChanged);
  }

  @override
  void onClose() {
    MainNavigationScreen.tabNotifier.removeListener(_onTabNotifierChanged);
    super.onClose();
  }

  void _onTabNotifierChanged() {
    currentIndex.value = MainNavigationScreen.tabNotifier.value;
  }

  void changeTab(int index) {
    MainNavigationScreen.tabNotifier.value = index;
  }
}