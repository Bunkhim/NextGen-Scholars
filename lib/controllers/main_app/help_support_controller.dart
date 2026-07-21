import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportController extends GetxController {
  final RxSet<int> expandedFaqs = <int>{}.obs;

  void toggleFaq(int index) {
    if (expandedFaqs.contains(index)) {
      expandedFaqs.remove(index);
    } else {
      expandedFaqs.add(index);
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // fallback: ignore if unable to launch
    }
  }
}