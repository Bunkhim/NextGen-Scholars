import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:url_launcher/url_launcher.dart';

part 'help_support_screen_controller.dart';
part 'help_support_screen_binding.dart';

class HelpSupportScreenView extends GetView<HelpSupportScreenViewController> {
  const HelpSupportScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
      appBar: AppBar(
        backgroundColor: WallpaperService().hasTheme
            ? WallpaperService().appBarColor
            : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: WallpaperService().hasTheme
                  ? WallpaperService().onThemeColor
                  : cs.onSurface,
              size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          t.translate('helpTitle'),
          style: TextStyle(
            color: WallpaperService().hasTheme
                ? WallpaperService().onThemeColor
                : cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: WallpaperService().hasTheme
                    ? WallpaperService().heroGradient(
                        fallbackColors: const [
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                        ],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (WallpaperService().hasTheme
                            ? WallpaperService().themedPrimary(cs)
                            : cs.primary)
                        .withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.translate('helpHeaderTitle'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.translate('helpHeaderSubtitle'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(t.translate('helpContactUs')),
            const SizedBox(height: 10),
            _ContactCard(
              items: [
                _ContactItem(
                  icon: Icons.email_outlined,
                  color: cs.primary,
                  title: t.translate('helpEmail'),
                  subtitle: 'choubkhunrithy@gmail.com',
                  onTap: () => controller.openLink('mailto:choubkhunrithy@gmail.com'),
                ),
                _ContactItem(
                  icon: Icons.phone_outlined,
                  color: Colors.green,
                  title: t.translate('helpPhone'),
                  subtitle: '+855 31 228 7763',
                  onTap: () => controller.openLink('tel:+855312287763'),
                ),
                _ContactItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: Colors.purple,
                  title: 'Telegram',
                  subtitle: '@scholarship_kh_bot',
                  onTap: () => controller.openLink('https://t.me/scholarship_kh_bot'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(t.translate('helpFaqTitle')),
            const SizedBox(height: 10),
            Obx(() => _buildFaqCard(isDark, cs, t)),
            const SizedBox(height: 24),
            _SectionLabel(t.translate('helpAbout')),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: WallpaperService().hasTheme
                  ? WallpaperService().glassCard(radius: 18)
                  : BoxDecoration(
                      color: isDark ? cs.surfaceContainerHighest : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0 : 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.translate('helpAboutText'),
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        '${t.translate('helpVersion')}: 1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(bool isDark, ColorScheme cs, AppLocalizations t) {
    final faqs = [
      {
        'q': t.translate('helpFaq1Q'),
        'a': t.translate('helpFaq1A'),
      },
      {
        'q': t.translate('helpFaq2Q'),
        'a': t.translate('helpFaq2A'),
      },
      {
        'q': t.translate('helpFaq3Q'),
        'a': t.translate('helpFaq3A'),
      },
      {
        'q': t.translate('helpFaq4Q'),
        'a': t.translate('helpFaq4A'),
      },
      {
        'q': t.translate('helpFaq5Q'),
        'a': t.translate('helpFaq5A'),
      },
    ];

    return Container(
      decoration: WallpaperService().hasTheme
          ? WallpaperService().glassCard(radius: 18)
          : BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: List.generate(faqs.length, (i) {
            final isExpanded = controller.expandedFaqs.contains(i);
            final isLast = i == faqs.length - 1;
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.toggleFaq(i);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: WallpaperService()
                                  .themedPrimary(cs)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: WallpaperService().themedPrimary(cs),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              faqs[i]['q']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.expand_more_rounded,
                                color: cs.onSurfaceVariant, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(60, 0, 16, 14),
                    child: Text(
                      faqs[i]['a']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color:
              themed ? ws.onThemeColor.withOpacity(0.7) : cs.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ContactItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ContactCard extends StatelessWidget {
  final List<_ContactItem> items;
  const _ContactCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: WallpaperService().hasTheme
          ? WallpaperService().glassCard(radius: 18)
          : BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(18) : Radius.zero,
                    bottom: isLast ? const Radius.circular(18) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: cs.outline, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 70),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: cs.outlineVariant.withOpacity(0.5),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
