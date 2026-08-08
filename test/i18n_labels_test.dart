import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

const _allDbCountries = [
  'USA',
  'United States',
  'UK',
  'United Kingdom',
  'Japan',
  'Australia',
  'Singapore',
  'South Korea',
  'Canada',
  'Germany',
  'France',
  'China',
  'Belgium',
  'European Union',
  'Italy',
  'Malaysia',
  'Multiple Countries',
  'Netherlands',
  'New Zealand',
  'Spain',
  'Sweden',
  'Switzerland',
];

const _allDbFundingTypes = [
  'Full',
  'Partial',
  'Tuition Only',
  'Tuition-only',
  'Living Stipend Only',
  'Stipend',
];

const _allDbDegrees = [
  'Bachelor',
  'Master',
  'PhD',
  'Postdoc',
  'Diploma',
];

FirestoreScholarship _scholarship(String country, String degree, String funding) {
  return FirestoreScholarship(
    id: 'id',
    titleEn: 't',
    titleKm: '',
    descriptionEn: '',
    descriptionKm: '',
    country: country,
    university: 'u',
    degree: degree,
    fieldOfStudy: 'f',
    fundingType: funding,
    applicationLink: '',
    deadline: DateTime(2026, 12, 31),
    createdAt: DateTime(2026, 1, 1),
  );
}

void _expectTranslated(String raw, String key, AppLocalizations km, AppLocalizations en) {
  final k = km.translate(key);
  final e = en.translate(key);
  expect(key, isNot(isEmpty), reason: 'mapping produced empty key for "$raw"');
  expect(k, isNot(key), reason: 'no Khmer translation for "$raw" (key "$key" missing)');
  expect(k, isNotEmpty, reason: 'empty Khmer translation for "$raw"');
  expect(k, isNot(raw), reason: 'Khmer translation fell back to raw English for "$raw"');
  expect(e, isNot(key), reason: 'EN translation missing for "$raw"');
  expect(e, isNotEmpty, reason: 'empty EN translation for "$raw"');
}

void main() {
  final km = AppLocalizations(const Locale('km'));
  final en = AppLocalizations(const Locale('en'));

  group('country → Khmer (FirestoreScholarship)', () {
    test('every DB country value has a Khmer translation', () {
      for (final c in _allDbCountries) {
        final sch = _scholarship(c, 'Bachelor', 'Full');
        _expectTranslated(c, sch.countryLabelKey, km, en);
      }
    });
  });

  group('country → Khmer (ScholarshipApplication)', () {
    test('every DB country value has a Khmer translation', () {
      for (final c in _allDbCountries) {
        final app = ScholarshipApplication(
          id: 'id',
          scholarshipId: 'sid',
          scholarshipTitle: 't',
          university: 'u',
          country: c,
          userId: 'uid',
          appliedAt: DateTime(2026, 1, 1),
          status: 'submitted',
        );
        _expectTranslated(c, app.countryLabelKey, km, en);
      }
    });
  });

  group('funding type → Khmer', () {
    test('every DB funding type has a Khmer translation', () {
      for (final f in _allDbFundingTypes) {
        final sch = _scholarship('Japan', 'Bachelor', f);
        _expectTranslated(f, sch.fundingTypeLabelKey, km, en);
      }
    });
  });

  group('degree → Khmer', () {
    test('every DB degree has a Khmer translation', () {
      for (final d in _allDbDegrees) {
        final sch = _scholarship('Japan', d, 'Full');
        _expectTranslated(d, sch.degreeLabelKey, km, en);
      }
    });
  });
}
