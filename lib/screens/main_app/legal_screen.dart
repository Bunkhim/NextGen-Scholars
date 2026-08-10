// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String? lastUpdated;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ws = WallpaperService();

    return Scaffold(
      backgroundColor: ws.hasAny ? Colors.transparent : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
      appBar: AppBar(
        backgroundColor: ws.hasTheme ? ws.appBarColor : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ws.hasTheme ? ws.onThemeColor : cs.onSurface,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: ws.hasTheme ? ws.onThemeColor : cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                lastUpdated!,
                style: TextStyle(color: cs.outline, fontSize: 13),
              ),
            ),
          for (final section in sections) ...[
            Text(
              section.heading,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            for (final paragraph in section.paragraphs) ...[
              Text(
                paragraph,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class LegalSection {
  final String heading;
  final List<String> paragraphs;

  const LegalSection(this.heading, this.paragraphs);
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<LegalSection> _sections = [
    LegalSection('1. Introduction', [
      'NextGen Scholarship ("we", "us", or "our") operates the mobile application and related services designed to help students discover scholarships and manage their applications. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our app.',
    ]),
    LegalSection('2. Information We Collect', [
      'Account information: your name, email address, phone number, and password when you register or sign in.',
      'Profile information: details you provide such as education level, grade, and preferences.',
      'Application content: the scholarship applications, documents, and files you upload or submit through the app.',
      'Device and usage information: device type, operating system, app version, and how you interact with the app, collected to improve our service.',
      'Notification preferences: your choices regarding push, email, and deadline notifications.',
    ]),
    LegalSection('3. How We Use Your Information', [
      'To provide, operate, and maintain the app and its features.',
      'To send you notifications about scholarships, application deadlines, and account updates that you have opted into.',
      'To improve, personalise, and troubleshoot the service.',
      'To detect, prevent, and address technical or security issues.',
    ]),
    LegalSection('4. How We Share Your Information', [
      'We do not sell your personal information.',
      'We may share data with trusted service providers (such as hosting and notification providers) who process it on our behalf under strict confidentiality obligations.',
      'We may disclose information when required by law, legal process, or to protect the rights and safety of our users and others.',
    ]),
    LegalSection('5. Data Security', [
      'We use reasonable technical and organisational measures, including encryption in transit, to protect your information. However, no method of transmission or storage is completely secure, and we cannot guarantee absolute security.',
    ]),
    LegalSection('6. Data Retention', [
      'We retain your information only for as long as necessary to provide the service, comply with legal obligations, or resolve disputes. When no longer needed, we delete or anonymise it.',
    ]),
    LegalSection('7. Your Rights', [
      'Depending on applicable law, you may have the right to access, correct, update, or delete the personal information we hold about you. You can contact us using the details below to exercise these rights, and we will respond within a reasonable time.',
    ]),
    LegalSection('8. Children\'s Privacy', [
      'The app is not intended for children under the age of 16. We do not knowingly collect personal information from children under this age. If you believe a child has provided us with personal information, please contact us and we will delete it.',
    ]),
    LegalSection('9. Changes to This Policy', [
      'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the updated policy within the app. Your continued use of the app after changes take effect constitutes acceptance of the revised policy.',
    ]),
    LegalSection('10. Contact Us', [
      'If you have questions about this Privacy Policy or your data, contact us at support@nextgenscholars.app.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return LegalScreen(
      title: AppLocalizations.of(context).translate('settingsPrivacyPolicy'),
      lastUpdated: 'Last updated: August 10, 2026',
      sections: _sections,
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const List<LegalSection> _sections = [
    LegalSection('1. Acceptance of Terms', [
      'By downloading, accessing, or using the NextGen Scholarship app, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.',
    ]),
    LegalSection('2. Eligibility', [
      'You must be at least 16 years old and have the legal capacity to accept these Terms to use the app. By using the app, you confirm that you meet these requirements.',
    ]),
    LegalSection('3. Accounts', [
      'You are responsible for providing accurate account information and for maintaining the confidentiality of your credentials. You are responsible for all activity that occurs under your account. Notify us promptly of any unauthorised use.',
    ]),
    LegalSection('4. Acceptable Use', [
      'You agree not to misuse the app, including by: violating any applicable law; attempting to access other users\' accounts; interfering with the service or its servers; uploading harmful content; or using the app to send spam, scams, or misleading information.',
    ]),
    LegalSection('5. User Content', [
      'You retain ownership of the content you submit or upload. You grant us a limited licence to store, process, and transmit your content solely to operate and provide the app. You are solely responsible for the content you submit and warrant that you have the right to submit it.',
    ]),
    LegalSection('6. Intellectual Property', [
      'The app, including its design, code, trademarks, and all non-user content, is owned by or licensed to us and is protected by intellectual property laws. You may not copy, modify, distribute, or create derivative works without our written permission.',
    ]),
    LegalSection('7. Third-Party Scholarships', [
      'The scholarships listed in the app are provided and administered by third parties. We do not control, and are not responsible for, their decisions, eligibility criteria, or application outcomes. Applying for any scholarship is at your own discretion.',
    ]),
    LegalSection('8. Disclaimer of Warranties', [
      'The app is provided "as is" and "as available" without warranties of any kind, whether express or implied, including merchantability, fitness for a particular purpose, and non-infringement. We do not warrant that the app will be uninterrupted, error-free, or free of harmful components.',
    ]),
    LegalSection('9. Limitation of Liability', [
      'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or data, arising from your use of or inability to use the app.',
    ]),
    LegalSection('10. Termination', [
      'We may suspend or terminate your access to the app at any time, with or without notice, if you violate these Terms or for operational reasons. You may stop using the app at any time.',
    ]),
    LegalSection('11. Governing Law', [
      'These Terms are governed by the laws of the Kingdom of Cambodia, without regard to conflict-of-law principles.',
    ]),
    LegalSection('12. Changes to These Terms', [
      'We may update these Terms from time to time. Material changes will be posted within the app. Your continued use of the app after changes take effect constitutes acceptance of the revised Terms.',
    ]),
    LegalSection('13. Contact Us', [
      'For questions about these Terms, contact us at support@nextgenscholars.app.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return LegalScreen(
      title: AppLocalizations.of(context).translate('settingsTermsOfService'),
      lastUpdated: 'Last updated: August 10, 2026',
      sections: _sections,
    );
  }
}
