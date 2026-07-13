// // ignore_for_file: deprecated_member_use

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:scholarship_app/translations/app_localizations.dart';
// import 'package:scholarship_app/routes/app_routes.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   final String email;

//   const ResetPasswordScreen({super.key, required this.email});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   bool _isLoading = false;
//   String? _passwordError;
//   String? _confirmError;
//   String? _errorMessage;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//           parent: _animationController,
//           curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)));
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   bool _isValidPassword(String p) {
//     return p.length >= 8 &&
//         p.contains(RegExp(r'[A-Z]')) &&
//         p.contains(RegExp(r'[a-z]')) &&
//         p.contains(RegExp(r'[0-9]')) &&
//         p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//   }

//   Future<void> _handleReset() async {
//     final t = AppLocalizations.of(context);
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _errorMessage = null;
//       _passwordError = null;
//       _confirmError = null;
//     });

//     final pwd = _passwordController.text;
//     final confirm = _confirmController.text;

//     if (pwd.isEmpty) {
//       setState(() =>
//           _passwordError = t.translate('registerPasswordRequired'));
//       return;
//     }
//     if (!_isValidPassword(pwd)) {
//       setState(() =>
//           _passwordError = t.translate('registerPasswordInvalid'));
//       return;
//     }
//     if (confirm != pwd) {
//       setState(
//           () => _confirmError = t.translate('registerPasswordsMismatch'));
//       return;
//     }

//     if (widget.email.isEmpty) {
//       setState(() => _errorMessage = t.translate('resetPasswordSessionExpired'));
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('https://scholarship-email-otp.onrender.com/api/reset-password'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': widget.email, 'newPassword': pwd}),
//       );

//       if (!mounted) return;
//       setState(() => _isLoading = false);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Row(children: [
//             const Icon(Icons.check_circle_rounded,
//                 color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(
//                 child: Text(t.translate('resetPasswordSuccess'),
//                     style:
//                         const TextStyle(fontWeight: FontWeight.w600))),
//           ]),
//           backgroundColor: const Color(0xFF10B981),
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           duration: const Duration(seconds: 2),
//         ));

//         await Future.delayed(const Duration(milliseconds: 1200));
//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(
//               context, AppRoutes.loginScreen, (r) => false);
//         }
//       } else {
//         Map<String, dynamic> body;
//         try {
//           body = jsonDecode(response.body) as Map<String, dynamic>;
//         } catch (_) {
//           body = {};
//         }
//         setState(() => _errorMessage =
//             (body['error'] as String?) ?? t.translate('resetPasswordFailed'));
//       }
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = t.translate('resetPasswordFailed');
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context);
//     final cs = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: cs.surface,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ── Gradient Header ──────────────────────────────────────
//             Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF1565C0),
//                     Color(0xFF1976D2),
//                     Color(0xFF2196F3),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(32),
//                   bottomRight: Radius.circular(32),
//                 ),
//               ),
//               child: SafeArea(
//                 bottom: false,
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(
//                               Icons.arrow_back_ios_new_rounded,
//                               color: Colors.white,
//                               size: 22,
//                             ),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                           Expanded(
//                             child: Text(
//                               t.translate('resetPasswordTitle'),
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 48),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         width: 76,
//                         height: 76,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.12),
//                               blurRadius: 20,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.lock_reset_rounded,
//                           size: 38,
//                           color: Color(0xFF1976D2),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         t.translate('resetPasswordSubtitle'),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                           letterSpacing: -0.3,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // ── Card Content ─────────────────────────────────────────
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: Column(
//                   children: [
//                     Transform.translate(
//                       offset: const Offset(0, -16),
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 20),
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: cs.surface,
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.08),
//                               blurRadius: 24,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // ── Error Banner ───────────────────────
//                             if (_errorMessage != null)
//                               Container(
//                                 width: double.infinity,
//                                 margin: const EdgeInsets.only(bottom: 16),
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: cs.error.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: cs.error.withOpacity(0.3),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.error_outline_rounded,
//                                         color: cs.error, size: 20),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         _errorMessage!,
//                                         style: TextStyle(
//                                           color: cs.error,
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                             // ── New Password ───────────────────────
//                             Row(
//                               children: [
//                                 Icon(Icons.lock_rounded,
//                                     size: 18, color: cs.primary),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   t.translate('resetPasswordNewLabel'),
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: cs.onSurfaceVariant,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             TextField(
//                               controller: _passwordController,
//                               obscureText: _obscurePassword,
//                               decoration: InputDecoration(
//                                 hintText: '••••••••',
//                                 errorText: _passwordError,
//                                 prefixIcon: Icon(Icons.lock_outline_rounded,
//                                     color: cs.onSurfaceVariant),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _obscurePassword
//                                         ? Icons.visibility_off_rounded
//                                         : Icons.visibility_rounded,
//                                     color: cs.onSurfaceVariant,
//                                   ),
//                                   onPressed: () => setState(
//                                       () => _obscurePassword = !_obscurePassword),
//                                 ),
//                                 filled: true,
//                                 fillColor: cs.surfaceContainerHighest
//                                     .withOpacity(0.4),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide: BorderSide(
//                                       color: cs.outlineVariant, width: 1.5),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide: BorderSide(
//                                       color: cs.outlineVariant, width: 1.5),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide:
//                                       BorderSide(color: cs.primary, width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide:
//                                       BorderSide(color: cs.error, width: 1.5),
//                                 ),
//                               ),
//                               onChanged: (_) {
//                                 if (_passwordError != null) {
//                                   setState(() => _passwordError = null);
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 20),

//                             // ── Confirm Password ───────────────────
//                             Row(
//                               children: [
//                                 Icon(Icons.lock_rounded,
//                                     size: 18, color: cs.primary),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   t.translate('resetPasswordConfirmLabel'),
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: cs.onSurfaceVariant,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             TextField(
//                               controller: _confirmController,
//                               obscureText: _obscureConfirm,
//                               decoration: InputDecoration(
//                                 hintText: '••••••••',
//                                 errorText: _confirmError,
//                                 prefixIcon: Icon(Icons.lock_outline_rounded,
//                                     color: cs.onSurfaceVariant),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _obscureConfirm
//                                         ? Icons.visibility_off_rounded
//                                         : Icons.visibility_rounded,
//                                     color: cs.onSurfaceVariant,
//                                   ),
//                                   onPressed: () => setState(
//                                       () => _obscureConfirm = !_obscureConfirm),
//                                 ),
//                                 filled: true,
//                                 fillColor: cs.surfaceContainerHighest
//                                     .withOpacity(0.4),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide: BorderSide(
//                                       color: cs.outlineVariant, width: 1.5),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide: BorderSide(
//                                       color: cs.outlineVariant, width: 1.5),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide:
//                                       BorderSide(color: cs.primary, width: 2),
//                                 ),
//                                 errorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                   borderSide:
//                                       BorderSide(color: cs.error, width: 1.5),
//                                 ),
//                               ),
//                               onChanged: (_) {
//                                 if (_confirmError != null) {
//                                   setState(() => _confirmError = null);
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 28),

//                             // ── Reset Button ───────────────────────
//                             SizedBox(
//                               width: double.infinity,
//                               height: 52,
//                               child: ElevatedButton(
//                                 onPressed: _isLoading ? null : _handleReset,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: cs.primary,
//                                   foregroundColor: cs.onPrimary,
//                                   disabledBackgroundColor:
//                                       cs.onSurface.withOpacity(0.12),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(14),
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 child: _isLoading
//                                     ? SizedBox(
//                                         height: 24,
//                                         width: 24,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2.5,
//                                           valueColor:
//                                               AlwaysStoppedAnimation<Color>(
//                                                   cs.onPrimary),
//                                         ),
//                                       )
//                                     : Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.lock_reset_rounded,
//                                               size: 20, color: cs.onPrimary),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             t.translate('resetPasswordButton'),
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                               letterSpacing: 0.3,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/controllers/authentication/reset_password_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final ResetPasswordController controller;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ResetPasswordController(email: widget.email));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF1976D2),
                    Color(0xFF2196F3),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              t.translate('resetPasswordTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 38,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.translate('resetPasswordSubtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Card Content ─────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Error Banner ───────────────────────
                            Obx(
                              () => controller.errorMessage.value != null
                                  ? Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: cs.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: cs.error.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline_rounded,
                                              color: cs.error, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              controller.errorMessage.value!,
                                              style: TextStyle(
                                                color: cs.error,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            // ── New Password ───────────────────────
                            Row(
                              children: [
                                Icon(Icons.lock_rounded,
                                    size: 18, color: cs.primary),
                                const SizedBox(width: 6),
                                Text(
                                  t.translate('resetPasswordNewLabel'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => TextField(
                                controller: controller.passwordController,
                                obscureText: controller.obscurePassword.value,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  errorText: controller.passwordError.value,
                                  prefixIcon: Icon(Icons.lock_outline_rounded,
                                      color: cs.onSurfaceVariant),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    onPressed:
                                        controller.togglePasswordVisibility,
                                  ),
                                  filled: true,
                                  fillColor: cs.surfaceContainerHighest
                                      .withOpacity(0.4),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.outlineVariant, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.outlineVariant, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.primary, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.error, width: 1.5),
                                  ),
                                ),
                                onChanged: (_) =>
                                    controller.clearPasswordError(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Confirm Password ───────────────────
                            Row(
                              children: [
                                Icon(Icons.lock_rounded,
                                    size: 18, color: cs.primary),
                                const SizedBox(width: 6),
                                Text(
                                  t.translate('resetPasswordConfirmLabel'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => TextField(
                                controller: controller.confirmController,
                                obscureText: controller.obscureConfirm.value,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  errorText: controller.confirmError.value,
                                  prefixIcon: Icon(Icons.lock_outline_rounded,
                                      color: cs.onSurfaceVariant),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureConfirm.value
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    onPressed:
                                        controller.toggleConfirmVisibility,
                                  ),
                                  filled: true,
                                  fillColor: cs.surfaceContainerHighest
                                      .withOpacity(0.4),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.outlineVariant, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.outlineVariant, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.primary, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: cs.error, width: 1.5),
                                  ),
                                ),
                                onChanged: (_) =>
                                    controller.clearConfirmError(),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Reset Button ───────────────────────
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () => controller.handleReset(t),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    disabledBackgroundColor:
                                        cs.onSurface.withOpacity(0.12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    cs.onPrimary),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock_reset_rounded,
                                                size: 20, color: cs.onPrimary),
                                            const SizedBox(width: 8),
                                            Text(
                                              t.translate(
                                                  'resetPasswordButton'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}