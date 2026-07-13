import 'package:get/get.dart';

class FilterResultController extends GetxController {
  final RxList<String> activeFilterKeys = [
    'filterChipComputerScience',
    'filterChipUnitedState',
    'filterChipFullScholarships',
  ].obs;

  final List<Map<String, String>> _allResultKeys = [
    {
      'titleKey': 'filterResultTitle1',
      'university': 'MIT',
      'locationKey': 'filterResultLocationUS',
      'typeKey': 'filterResultTypeFullScholarship',
      'deadline': '2026-02-14',
    },
    {
      'titleKey': 'filterResultTitle1',
      'university': 'Stanford',
      'locationKey': 'filterResultLocationUSA',
      'typeKey': 'filterResultTypeFullScholarship',
      'deadline': '2026-02-14',
    },
  ];

  List<Map<String, String>> get filteredResults => _allResultKeys;

  void removeFilter(String filterKey) {
    activeFilterKeys.remove(filterKey);
  }
}
