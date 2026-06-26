part of 'notification_screen_view.dart';

class NotificationScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationScreenViewController());
  }
}
