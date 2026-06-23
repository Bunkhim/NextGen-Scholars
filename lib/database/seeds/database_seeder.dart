import '../../data/models/scholarship_model.dart';
import '../../data/repositories/scholarship_repository.dart';

/// Seeds initial scholarship data into the database.
/// Only runs if the scholarships table is empty.
class DatabaseSeeder {
  final ScholarshipRepository _repo = ScholarshipRepository();

  /// Seed default scholarships if table is empty.
  Future<void> seedIfEmpty() async {
    final count = await _repo.count();
    if (count > 0) return;

    await _repo.insertAll(_defaultScholarships);
  }

  static final List<Scholarship> _defaultScholarships = [
    Scholarship(
      title: 'MEXT Scholarship (Japanese Government)',
      titleKm: 'អាហារូបករណ៍ MEXT (រដ្ឋាភិបាលជប៉ុន)',
      institution: 'Japanese Government (MEXT)',
      institutionKm: 'រដ្ឋាភិបាលជប៉ុន (MEXT)',
      country: 'Japan',
      countryKm: 'ជប៉ុន',
      type: 'Full Scholarship',
      typeKm: 'អាហារូបករណ៍ពេញ',
      description:
          'The MEXT scholarship covers tuition, monthly allowance, round-trip airfare, and settling-in allowance for international students.',
      descriptionKm:
          'អាហារូបករណ៍ MEXT គ្របដណ្ដប់ថ្លៃសិក្សា ប្រាក់ខែ សំបុត្រយន្តហោះទៅមក និងប្រាក់ឧបត្ថម្ភសម្រាប់និស្សិតអន្តរជាតិ។',
      deadline: DateTime(2026, 5, 15),
      amount: '¥143,000/month',
      currency: 'JPY',
      level: 'Master, PhD',
      fieldOfStudy: 'All Fields',
      isFeatured: true,
      isActive: true,
      eligibility:
          'Must be under 35 years old. Must have completed or be expected to complete undergraduate education.',
      benefits:
          'Full tuition waiver, monthly stipend, round-trip airfare, settling-in allowance.',
      requiredDocuments:
          'Application form, academic transcripts, recommendation letters, research plan, language certificates.',
      applicationUrl: 'https://www.studyinjapan.go.jp/en/scholarship/',
    ),
    Scholarship(
      title: 'Chevening Scholarship (UK Government)',
      titleKm: 'អាហារូបករណ៍ Chevening (រដ្ឋាភិបាលអង់គ្លេស)',
      institution: 'UK Foreign, Commonwealth & Development Office',
      institutionKm: 'ការិយាល័យកិច្ចការបរទេស សមភាពជាតិ និងអភិវឌ្ឍន៍អង់គ្លេស',
      country: 'United Kingdom',
      countryKm: 'អង់គ្លេស',
      type: 'Full Scholarship',
      typeKm: 'អាហារូបករណ៍ពេញ',
      description:
          'Chevening offers fully funded Master\'s degrees for outstanding emerging leaders from around the world.',
      deadline: DateTime(2026, 11, 1),
      amount: 'Full Funding',
      currency: 'GBP',
      level: 'Master',
      fieldOfStudy: 'All Fields',
      isFeatured: true,
      isActive: true,
      eligibility:
          'Minimum 2 years of work experience. Must return to home country for minimum 2 years after studies.',
      benefits:
          'Full tuition, monthly stipend, travel costs, arrival allowance, thesis/dissertation grant.',
      applicationUrl: 'https://www.chevening.org/',
    ),
    Scholarship(
      title: 'Korean Government Scholarship Program (KGSP)',
      titleKm: 'អាហារូបករណ៍រដ្ឋាភិបាលកូរ៉េ (KGSP)',
      institution: 'National Institute for International Education (NIIED)',
      institutionKm: 'វិទ្យាស្ថានជាតិសម្រាប់ការអប់រំអន្តរជាតិ (NIIED)',
      country: 'South Korea',
      countryKm: 'កូរ៉េខាងត្បូង',
      type: 'Full Scholarship',
      typeKm: 'អាហារូបករណ៍ពេញ',
      description:
          'KGSP provides international students with opportunities to pursue studies at Korean higher education institutions.',
      deadline: DateTime(2026, 3, 30),
      amount: '₩900,000/month',
      currency: 'KRW',
      level: 'Bachelor, Master, PhD',
      fieldOfStudy: 'All Fields',
      isFeatured: true,
      isActive: true,
      eligibility:
          'Must be a citizen of a country that has diplomatic relations with South Korea. Must meet GPA requirements.',
      benefits:
          'Full tuition, monthly allowance, settlement fund, Korean language training, medical insurance, round-trip airfare.',
      applicationUrl: 'https://www.studyinkorea.go.kr/',
    ),
    Scholarship(
      title: 'Australia Awards Scholarships',
      titleKm: 'អាហារូបករណ៍ Australia Awards',
      institution: 'Australian Government (DFAT)',
      institutionKm: 'រដ្ឋាភិបាលអូស្ត្រាលី (DFAT)',
      country: 'Australia',
      countryKm: 'អូស្ត្រាលី',
      type: 'Full Scholarship',
      typeKm: 'អាហារូបករណ៍ពេញ',
      description:
          'Australia Awards aim to develop partnerships and links at the individual, institutional, and country levels.',
      deadline: DateTime(2026, 4, 30),
      amount: 'AUD 30,000+/year',
      currency: 'AUD',
      level: 'Master, PhD',
      fieldOfStudy: 'Priority areas for Cambodia',
      isFeatured: false,
      isActive: true,
      eligibility:
          'Must be a citizen of a participating country (Cambodia eligible). Must not hold Australian citizenship or permanent residency.',
      benefits:
          'Full tuition, return air travel, establishment allowance, contribution to living expenses, health insurance.',
      applicationUrl:
          'https://www.dfat.gov.au/people-to-people/australia-awards/',
    ),
    Scholarship(
      title: 'Erasmus Mundus Joint Masters',
      titleKm: 'កម្មវិធីអនុបណ្ឌិត Erasmus Mundus',
      institution: 'European Commission',
      institutionKm: 'គណៈកម្មាធិការអឺរ៉ុប',
      country: 'Europe (Multiple)',
      countryKm: 'អឺរ៉ុប (ច្រើនប្រទេស)',
      type: 'Full Scholarship',
      typeKm: 'អាហារូបករណ៍ពេញ',
      description:
          'Study in at least two European countries with world-class joint Master programmes.',
      deadline: DateTime(2026, 1, 15),
      amount: '€1,400/month',
      currency: 'EUR',
      level: 'Master',
      fieldOfStudy: 'Various',
      isFeatured: false,
      isActive: true,
      eligibility:
          'Must hold a first higher education degree (Bachelor or equivalent).',
      benefits:
          'Tuition coverage, monthly allowance, travel costs, installation costs, insurance.',
      applicationUrl: 'https://erasmus-plus.ec.europa.eu/',
    ),
    Scholarship(
      title: 'Chinese Government Scholarship (CSC)',
      titleKm: 'អាហារូបករណ៍រដ្ឋាភិបាលចិន (CSC)',
      institution: 'China Scholarship Council',
      institutionKm: 'ក្រុមប្រឹក្សាអាហារូបករណ៍ចិន',
      country: 'China',
      countryKm: 'ចិន',
      type: 'Full Scholarship',
      typeKm: 'អាហារូបករណ៍ពេញ',
      description:
          'The CSC scholarship supports international students pursuing various degrees in Chinese universities.',
      deadline: DateTime(2026, 3, 1),
      amount: '¥3,500/month',
      currency: 'CNY',
      level: 'Bachelor, Master, PhD',
      fieldOfStudy: 'All Fields',
      isFeatured: true,
      isActive: true,
      eligibility:
          'Age requirements vary by degree level. Must be a non-Chinese citizen in good health.',
      benefits:
          'Full tuition, accommodation, monthly stipend, medical insurance.',
      applicationUrl: 'https://www.csc.edu.cn/',
    ),
  ];
}
