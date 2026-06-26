// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

part 'search_filter_screen_controller.dart';
part 'search_filter_screen_binding.dart';

class SearchFilterScreenView extends GetView<SearchFilterScreenViewController> {
  const SearchFilterScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Expanded(
                          child: Text(
                            t.translate('searchTitle'),
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 46),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Obx(() => TextField(
                              controller: controller.searchController,
                              focusNode: controller.focusNode,
                              autofocus: true,
                              maxLength: 100,
                              style: TextStyle(color: colorScheme.onSurface),
                              onChanged: (value) {
                                final sanitized = controller.sanitizeInput(value);
                                if (sanitized != value) {
                                  controller.searchController.text = sanitized;
                                  controller.searchController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(offset: sanitized.length),
                                  );
                                }
                                controller.searchError.value = null;
                              },
                              decoration: InputDecoration(
                                hintText: t.translate('searchHint'),
                                hintStyle: TextStyle(
                                  color: colorScheme.outline,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: controller.searchError.value != null
                                      ? Colors.red
                                      : colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                                counterText: '',
                              ),
                              onSubmitted: (val) {
                                final sanitized = controller.sanitizeInput(val);
                                if (sanitized.isEmpty) {
                                  controller.searchError.value =
                                      t.translate('validationSearchEmpty');
                                  return;
                                }
                                Get.back(result: sanitized);
                              },
                            )),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.openFilter(context),
                          child: Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: colorScheme.onPrimary.withOpacity(0.5)),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: colorScheme.onPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.searchError.value == null) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              controller.searchError.value!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    t.translate('searchRecentTitle'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(controller.getRecentSearches(t).length, (i) {
                    final recentSearches = controller.getRecentSearches(t);
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => controller.onRecentTap(recentSearches[i]),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(recentSearches[i], style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                                ),
                                Icon(Icons.arrow_forward_ios, color: colorScheme.outline, size: 14),
                              ],
                            ),
                          ),
                        ),
                        if (i < recentSearches.length - 1)
                          Divider(height: 1, color: colorScheme.outlineVariant),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    t.translate('searchPopularTitle'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.getPopularSearches(t).map((tag) {
                      return GestureDetector(
                        onTap: () => controller.onPopularTap(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedCountryRaw;
  String? _selectedTypeRaw;

  static const _countryMap = {
    'United States': 'filterCountryUnitedStates',
    'United Kingdom': 'filterCountryUnitedKingdom',
    'Japan': 'filterCountryJapan',
    'Australia': 'filterCountryAustralia',
    'Singapore': 'filterCountrySingapore',
    'South Korea': 'filterCountrySouthKorea',
    'Canada': 'filterCountryCanada',
    'Germany': 'filterCountryGermany',
    'France': 'filterCountryFrance',
    'China': 'filterCountryChina',
  };

  static const _typeMap = {
    'Full': 'filterTypeFullScholarship',
    'Partial': 'filterTypePartialScholarship',
    'Tuition-only': 'filterTypeTuitionOnly',
    'Stipend': 'filterTypeStipend',
  };

  List<MapEntry<String, String>> _getCountries(AppLocalizations t) =>
      _countryMap.entries
          .map((e) => MapEntry(e.key, t.translate(e.value)))
          .toList();

  List<MapEntry<String, String>> _getTypes(AppLocalizations t) =>
      _typeMap.entries
          .map((e) => MapEntry(e.key, t.translate(e.value)))
          .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(t.translate('searchFilterTitle'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const SizedBox(height: 20),
          Text(t.translate('searchCountryLabel'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _getCountries(t).map((entry) {
              final raw = entry.key;
              final display = entry.value;
              final selected = _selectedCountryRaw == raw;
              return GestureDetector(
                onTap: () => setState(() => _selectedCountryRaw = selected ? null : raw),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? colorScheme.primary : colorScheme.outline,
                    ),
                  ),
                  child: Text(display, style: TextStyle(
                    fontSize: 13,
                    color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(t.translate('searchScholarshipTypeLabel'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _getTypes(t).map((entry) {
              final raw = entry.key;
              final display = entry.value;
              final selected = _selectedTypeRaw == raw;
              return GestureDetector(
                onTap: () => setState(() => _selectedTypeRaw = selected ? null : raw),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? colorScheme.primary : colorScheme.outline,
                    ),
                  ),
                  child: Text(display, style: TextStyle(
                    fontSize: 13,
                    color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.back(result: {
                  'country': _selectedCountryRaw,
                  'type': _selectedTypeRaw,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(t.translate('searchApplyFiltersButton'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onPrimary)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
        ],
      ),
    );
  }
}
