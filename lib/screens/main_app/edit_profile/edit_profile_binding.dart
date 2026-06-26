part of 'edit_profile_view.dart';

class EditProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileViewController());
  }
}
