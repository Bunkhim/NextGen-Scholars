part of 'filter_result_screen_view.dart';

class FilterResultScreenViewController extends GetxController {
  final activeFilterKeys = <String>[].obs;

  final List<Map<String, String>> allResultKeys = [
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

  List<Map<String, String>> get filteredResults => allResultKeys;

  @override
  void onInit() {
    super.onInit();
    activeFilterKeys.addAll([
      'filterChipComputerScience',
      'filterChipUnitedState',
      'filterChipFullScholarships',
    ]);
  }

  void removeFilter(String filterKey) {
    activeFilterKeys.remove(filterKey);
  }
}
