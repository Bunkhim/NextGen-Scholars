part of 'homescreens_view.dart';

class HomeScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeScreenViewController());
  }
}
