part of 'help_support_screen_view.dart';

class HelpSupportScreenViewController extends GetxController {
  final expandedFaqs = <int>{}.obs;

  void toggleFaq(int i) {
    if (expandedFaqs.contains(i)) {
      expandedFaqs.remove(i);
    } else {
      expandedFaqs.add(i);
    }
  }

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
