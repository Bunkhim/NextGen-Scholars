// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/main_app/notification_controller.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/notification_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final isKm = Localizations.localeOf(context).languageCode == 'km';

    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : colorScheme.surfaceContainerHighest,
      body: Obx(() {
        if (!controller.settingsLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final notifications = controller.notifications;
        final unreadCount = controller.unreadCount;

        return CustomScrollView(
          slivers: [
                    // AppBar
                    SliverAppBar(
                      backgroundColor: WallpaperService().hasTheme
                          ? WallpaperService().appBarColor
                          : colorScheme.surface,
                      elevation: 0,
                      surfaceTintColor: WallpaperService().hasTheme
                          ? Colors.transparent
                          : colorScheme.surface,
                      pinned: true,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: WallpaperService().hasTheme
                                ? WallpaperService().onThemeColor
                                : colorScheme.onSurface,
                            size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.translate('notificationTitle'),
                            style: TextStyle(
                              color: WallpaperService().hasTheme
                                  ? WallpaperService().onThemeColor
                                  : colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (unreadCount > 0)
                            Text(
                              "$unreadCount ${t.translate('notificationUnreadCount')}",
                              style: TextStyle(
                                color: WallpaperService().hasTheme
                                    ? WallpaperService()
                                        .onThemeColor
                                        .withOpacity(0.7)
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      actions: [
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: () => controller.markAllAsRead(),
                            child: Text(
                              t.translate('notificationMarkAllRead'),
                              style: TextStyle(
                                color: WallpaperService()
                                    .themedPrimary(colorScheme),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    // Content
                    if (notifications.isEmpty)
                      SliverFillRemaining(
                        child: _buildEmptyState(colorScheme, t),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = notifications[index];
                              return _SwipeableNotificationCard(
                                key: ValueKey(item.id),
                                item: item,
                                colorScheme: colorScheme,
                                isKm: isKm,
                                controller: controller,
                              );
                            },
                            childCount: notifications.length,
                          ),
                        ),
                      ),
                  ],
                );
      }),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations t) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: themed
                  ? Colors.white.withOpacity(0.12)
                  : colorScheme.outlineVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: themed
                  ? ws.onThemeColor.withOpacity(0.6)
                  : colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.translate('notificationEmpty'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ws.themedOnSurface(colorScheme),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.translate('notificationAllCaughtUp'),
            style: TextStyle(
              fontSize: 14,
              color: ws.themedOnSurfaceVariant(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Swipeable notification card ──────────────────────────────────────────────
// • Swipe left → right  : immediately clears the notification
// • Swipe right → left  : slides to reveal a red "Clear" button
class _SwipeableNotificationCard extends StatefulWidget {
  final AppNotification item;
  final ColorScheme colorScheme;
  final bool isKm;
  final NotificationController controller;

  const _SwipeableNotificationCard({
    required super.key,
    required this.item,
    required this.colorScheme,
    required this.isKm,
    required this.controller,
  });

  @override
  State<_SwipeableNotificationCard> createState() =>
      _SwipeableNotificationCardState();
}

class _SwipeableNotificationCardState extends State<_SwipeableNotificationCard>
    with SingleTickerProviderStateMixin {
  static const double _btnWidth = 80.0;

  double _offset = 0;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late Animation<double> _anim = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() => _offset = _anim.value);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _snapTo(double target) {
    _ctrl.stop();
    _anim = Tween<double>(begin: _offset, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward(from: 0);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _ctrl.stop();
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(-_btnWidth, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_offset >= screenWidth * 0.35) {
      // Swipe left→right: slide off screen then dismiss
      _snapTo(screenWidth);
      Future.delayed(const Duration(milliseconds: 220), () {
        widget.controller.dismissNotification(widget.item.id);
      });
    } else if (_offset <= -_btnWidth / 2) {
      _snapTo(-_btnWidth); // Reveal "Clear" button
    } else {
      _snapTo(0); // Snap back
    }
  }

  void _dismissCard() {
    _snapTo(MediaQuery.of(context).size.width);
    Future.delayed(const Duration(milliseconds: 220), () {
      widget.controller.dismissNotification(widget.item.id);
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final colorScheme = widget.colorScheme;
    final isKm = widget.isKm;

    final title = (isKm && item.titleKm != null && item.titleKm!.isNotEmpty)
        ? item.titleKm!
        : item.title;
    final body = (isKm && item.bodyKm != null && item.bodyKm!.isNotEmpty)
        ? item.bodyKm!
        : item.body;

    IconData icon;
    Color iconColor;
    switch (item.type) {
      case 'new_scholarship':
        icon = Icons.school;
        iconColor = const Color(0xFF4ECDC4);
        break;
      case 'application_status':
        icon = Icons.assignment_turned_in;
        iconColor = const Color(0xFF95E1D3);
        break;
      default:
        icon = Icons.notifications_active;
        iconColor = const Color(0xFFFF6B6B);
    }

    final timeAgo =
        item.createdAt != null ? _formatTimeAgo(item.createdAt!) : '';
    final ws = WallpaperService();
    final themed = ws.hasTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // ── Left-to-right dismiss hint ───────────────────────
              if (_offset > 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Right-to-left revealed "Clear" button ────────────
              if (_offset < 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _dismissCard,
                    child: Container(
                      width: _btnWidth,
                      color: Colors.red.shade600,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_rounded,
                              color: Colors.white, size: 24),
                          SizedBox(height: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Sliding card ─────────────────────────────────────
              Transform.translate(
                offset: Offset(_offset, 0),
                child: Container(
                  decoration: themed
                      ? ws.glassCard(radius: 12)
                      : BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (_offset != 0) {
                          _snapTo(0);
                        } else if (!item.isRead) {
                          widget.controller.markAsRead(item.id);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: iconColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: item.isRead
                                                ? FontWeight.w500
                                                : FontWeight.w600,
                                            color: item.isRead
                                                ? colorScheme.onSurfaceVariant
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (!item.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    body,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: item.isRead
                                          ? colorScheme.outline
                                          : colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (timeAgo.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 12,
                                            color: colorScheme.outline),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeAgo,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
