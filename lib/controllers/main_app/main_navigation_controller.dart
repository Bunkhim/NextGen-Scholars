import 'package:get/get.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    MainNavigationScreen.tabNotifier.value = index;
  }
}
