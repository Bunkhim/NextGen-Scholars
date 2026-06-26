part of 'chat_ai_screen_view.dart';

class ChatAiScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatAiScreenViewController());
  }
}
