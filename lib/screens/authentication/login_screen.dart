// // ignore_for_file: deprecated_member_use

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:scholarship_app/translations/app_localizations.dart';
// import 'package:scholarship_app/routes/app_routes.dart';
// import 'package:scholarship_app/services/fill_info_persistence_service.dart';
// import 'package:scholarship_app/services/session_security_service.dart';
// import 'package:scholarship_app/services/user_data_sync_service.dart';
// import 'package:scholarship_app/services/user_firestore_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   // ============ CONTROLLERS & FORM ============
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _emailFocusNode = FocusNode();
//   final _passwordFocusNode = FocusNode();

//   // ============ STATE ============
//   bool _obscurePassword = true;
//   bool _isLoading = false;
//   bool _isGoogleLoading = false;
//   bool _isFacebookLoading = false;

//   // ============ ANIMATIONS ============
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // ============ LIFECYCLE ============

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 900),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//       ),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.06),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   // ============ VALIDATION ============

//   String? _validateEmail(String? value) {
//     final t = AppLocalizations.of(context);
//     if (value == null || value.isEmpty) {
//       return t.translate('loginEmailRequired');
//     }
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) {
//       return t.translate('loginEmailInvalid');
//     }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     final t = AppLocalizations.of(context);
//     if (value == null || value.isEmpty) {
//       return t.translate('loginPasswordRequired');
//     }
//     if (value.length < 8) {
//       return t.translate('loginPasswordMinLength');
//     }
//     return null;
//   }

//   // ============ MESSAGES ============

//   void _showMessage({
//     required String message,
//     String? subtitle,
//     required Color backgroundColor,
//     required IconData icon,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: Colors.white, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     message,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   if (subtitle != null) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.white.withOpacity(0.85),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height - 150,
//           left: 20,
//           right: 20,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         duration: const Duration(seconds: 3),
//         elevation: 8,
//       ),
//     );
//   }

//   void _showSuccessMessage(String message, String userName) {
//     _showMessage(
//       message: message,
//       subtitle: AppLocalizations.of(context)
//           .translate('loginWelcomeUser')
//           .replaceAll('\$userName', userName),
//       backgroundColor: const Color(0xff10B981),
//       icon: Icons.check_circle_rounded,
//     );
//   }

//   void _showErrorMessage(String message) {
//     _showMessage(
//       message: message,
//       backgroundColor: const Color(0xffEF4444),
//       icon: Icons.error_rounded,
//     );
//   }

//   // ============ AUTHENTICATION ============

//   Future<void> _handleLogin() async {
//     final t = AppLocalizations.of(context);
//     FocusScope.of(context).unfocus();

//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       // Real Firebase Auth sign-in
//       final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       if (!mounted) return;

//       final user = credential.user;
//       final userName = user?.displayName ?? _emailController.text.split('@')[0];

//       // Update lastLoginAt in Firestore
//       if (user != null) {
//         await UserFirestoreService().updateLastLogin(user.uid);
//         // Restore per-user Fill Info from local storage
//         await FillInfoPersistenceService().onUserLoggedIn(user.uid);
//         // Record login for weekly session security check
//         await SessionSecurityService().recordLogin();
//         // Restore all app data from Firestore (if reinstalled)
//         await UserDataSyncService().restoreAll(user.uid);
//       }

//       setState(() => _isLoading = false);
//       _showSuccessMessage(t.translate('loginSuccess'), userName);

//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);

//       String errorMsg;
//       switch (e.code) {
//         case 'user-not-found':
//           errorMsg = t.translate('loginErrorUserNotFound');
//           break;
//         case 'wrong-password':
//           errorMsg = t.translate('loginErrorWrongPassword');
//           break;
//         case 'invalid-credential':
//           errorMsg = t.translate('loginErrorInvalidCredential');
//           break;
//         case 'user-disabled':
//           errorMsg = t.translate('loginErrorUserDisabled');
//           break;
//         case 'too-many-requests':
//           errorMsg = t.translate('loginErrorTooManyRequests');
//           break;
//         default:
//           errorMsg = e.message ?? t.translate('loginFailed');
//       }
//       _showErrorMessage(errorMsg);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//       _showErrorMessage(t.translate('loginFailed'));
//     }
//   }

//   Future<void> _handleGoogleSignIn() async {
//     final t = AppLocalizations.of(context);
//     FocusScope.of(context).unfocus();
//     setState(() => _isGoogleLoading = true);

//     try {
//       _showLoadingDialog(t.translate('loginGoogleSigningIn'));

//       final GoogleSignIn googleSignIn = GoogleSignIn(
//         clientId: null,
//         scopes: <String>['email', 'profile'],
//       );

//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (!mounted) return;
//       Navigator.pop(context);

//       if (googleUser == null) {
//         setState(() => _isGoogleLoading = false);
//         _showErrorMessage(t.translate('loginGoogleCancelled'));
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithCredential(credential);

//       if (!mounted) return;

//       final User? user = userCredential.user;
//       final String userName = user?.displayName ?? 'User';

//       // Sync user to Firestore (create if first time, update lastLoginAt)
//       if (user != null) {
//         await UserFirestoreService().ensureUser(user);
//         // Restore per-user Fill Info from local storage
//         await FillInfoPersistenceService().onUserLoggedIn(user.uid);
//         // Record login for weekly session security check
//         await SessionSecurityService().recordLogin();
//         // Restore all app data from Firestore (if reinstalled)
//         await UserDataSyncService().restoreAll(user.uid);
//       }

//       setState(() => _isGoogleLoading = false);
//       _showSuccessMessage(
//         t
//             .translate('loginGoogleWelcomeUser')
//             .replaceAll('\$userName', userName),
//         t.translate('loginGoogleSignInSuccess'),
//       );

//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context);
//       setState(() => _isGoogleLoading = false);

//       String errorMessage = t.translate('loginAuthFailed');
//       if (e.code == 'account-exists-with-different-credential') {
//         errorMessage = t.translate('loginEmailExistsDifferentMethod');
//       } else if (e.code == 'invalid-credential') {
//         errorMessage = t.translate('loginInvalidCredentials');
//       }
//       _showErrorMessage(errorMessage);
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context);
//       setState(() => _isGoogleLoading = false);
//       _showErrorMessage(t.translate('loginGoogleFailed'));
//     }
//   }

//   void _showLoadingDialog(String message) {
//     final colorScheme = Theme.of(context).colorScheme;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: colorScheme.surface,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: 44,
//                   height: 44,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     valueColor:
//                         AlwaysStoppedAnimation<Color>(colorScheme.primary),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   message,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _handleFacebookSignIn() async {
//     final t = AppLocalizations.of(context);
//     FocusScope.of(context).unfocus();
//     setState(() => _isFacebookLoading = true);

//     try {
//       _showLoadingDialog(t.translate('loginFacebookSigningIn'));

//       final LoginResult result = await FacebookAuth.instance.login(
//         permissions: ['email', 'public_profile'],
//       );

//       if (!mounted) return;
//       Navigator.pop(context); // dismiss loading dialog

//       if (result.status == LoginStatus.cancelled) {
//         setState(() => _isFacebookLoading = false);
//         _showErrorMessage(t.translate('loginFacebookCancelled'));
//         return;
//       }

//       if (result.status != LoginStatus.success || result.accessToken == null) {
//         setState(() => _isFacebookLoading = false);
//         _showErrorMessage(t.translate('loginFacebookFailed'));
//         return;
//       }

//       final OAuthCredential facebookCredential =
//           FacebookAuthProvider.credential(result.accessToken!.tokenString);

//       final UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithCredential(facebookCredential);

//       if (!mounted) return;

//       final User? user = userCredential.user;
//       final String userName = user?.displayName ?? 'User';

//       if (user != null) {
//         await UserFirestoreService().ensureUser(user);
//         // Restore per-user Fill Info from local storage
//         await FillInfoPersistenceService().onUserLoggedIn(user.uid);
//         // Record login for weekly session security check
//         await SessionSecurityService().recordLogin();
//         // Restore all app data from Firestore (if reinstalled)
//         await UserDataSyncService().restoreAll(user.uid);
//       }

//       setState(() => _isFacebookLoading = false);
//       _showSuccessMessage(
//         t.translate('loginFacebookSignInSuccess'),
//         userName,
//       );

//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;
//       if (Navigator.canPop(context)) Navigator.pop(context);
//       setState(() => _isFacebookLoading = false);

//       String errorMessage = t.translate('loginAuthFailed');
//       if (e.code == 'account-exists-with-different-credential') {
//         errorMessage = t.translate('loginEmailExistsDifferentMethod');
//       } else if (e.code == 'invalid-credential') {
//         errorMessage = t.translate('loginInvalidCredentials');
//       }
//       _showErrorMessage(errorMessage);
//     } catch (e) {
//       if (!mounted) return;
//       if (Navigator.canPop(context)) Navigator.pop(context);
//       setState(() => _isFacebookLoading = false);
//       _showErrorMessage(t.translate('loginFacebookFailed'));
//     }
//   }

//   void _handleEmailSignIn() {
//     _emailFocusNode.requestFocus();
//   }

//   // ============ INPUT DECORATION ============

//   InputDecoration _inputDecoration({
//     required String hint,
//     required IconData prefixIcon,
//     Widget? suffixIcon,
//     required ColorScheme colorScheme,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(
//         color: colorScheme.onSurfaceVariant.withOpacity(0.5),
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//       ),
//       prefixIcon: Container(
//         margin: const EdgeInsets.only(left: 4),
//         child: Icon(prefixIcon, color: colorScheme.onSurfaceVariant, size: 20),
//       ),
//       suffixIcon: suffixIcon,
//       filled: true,
//       fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(
//           color: colorScheme.outlineVariant.withOpacity(0.5),
//           width: 1,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: colorScheme.error, width: 1.5),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: colorScheme.error, width: 1.8),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       errorStyle: const TextStyle(fontSize: 12, height: 1.2),
//     );
//   }

//   // ============ BUILD ============

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final t = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // ── Gradient Header ─────────────────────────────────────
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.only(
//                     top: MediaQuery.of(context).padding.top + 20,
//                     bottom: 36,
//                   ),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Color(0xFF1565C0),
//                         Color(0xFF1976D2),
//                         Color(0xFF2196F3),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(32),
//                       bottomRight: Radius.circular(32),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Hero(
//                         tag: 'app_logo',
//                         child: Container(
//                           width: 88,
//                           height: 88,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF0D47A1).withOpacity(0.3),
//                                 blurRadius: 24,
//                                 offset: const Offset(0, 8),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(14),
//                           child: Image.asset(
//                             "assets/icons/nextgen_logo.png",
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         t.translate('loginWelcomeTitle'),
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                           letterSpacing: -0.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         t.translate('loginSubtitle'),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white.withOpacity(0.85),
//                           height: 1.4,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ── Form Card ───────────────────────────────────────────
//                 Transform.translate(
//                   offset: const Offset(0, -16),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
//                     decoration: BoxDecoration(
//                       color: colorScheme.surface,
//                       borderRadius: BorderRadius.circular(24),
//                       boxShadow: [
//                         BoxShadow(
//                           color: colorScheme.shadow.withOpacity(0.08),
//                           blurRadius: 24,
//                           offset: const Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Email
//                           Text(
//                             t.translate('loginEmailLabel'),
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: colorScheme.onSurface,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: _emailController,
//                             focusNode: _emailFocusNode,
//                             keyboardType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                             validator: _validateEmail,
//                             onFieldSubmitted: (_) =>
//                                 _passwordFocusNode.requestFocus(),
//                             cursorHeight: 20,
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: colorScheme.onSurface,
//                             ),
//                             decoration: _inputDecoration(
//                               hint: t.translate('loginEmailHint'),
//                               prefixIcon: Icons.email_outlined,
//                               colorScheme: colorScheme,
//                             ),
//                           ),

//                           const SizedBox(height: 20),

//                           // Password
//                           Text(
//                             t.translate('loginPasswordLabel'),
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: colorScheme.onSurface,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: _passwordController,
//                             focusNode: _passwordFocusNode,
//                             obscureText: _obscurePassword,
//                             textInputAction: TextInputAction.done,
//                             validator: _validatePassword,
//                             onFieldSubmitted: (_) => _handleLogin(),
//                             cursorHeight: 20,
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: colorScheme.onSurface,
//                             ),
//                             decoration: _inputDecoration(
//                               hint: t.translate('loginPasswordHint'),
//                               prefixIcon: Icons.lock_outlined,
//                               colorScheme: colorScheme,
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscurePassword
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: colorScheme.onSurfaceVariant,
//                                   size: 20,
//                                 ),
//                                 onPressed: () => setState(
//                                     () => _obscurePassword = !_obscurePassword),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // Forgot password
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: TextButton(
//                               onPressed: () => Navigator.pushNamed(
//                                   context, AppRoutes.forgetPasswordScreen),
//                               style: TextButton.styleFrom(
//                                 padding: EdgeInsets.zero,
//                                 minimumSize: const Size(0, 0),
//                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                               ),
//                               child: Text(
//                                 t.translate('loginForgotPassword'),
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   color: colorScheme.primary,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 24),

//                           // Login button
//                           SizedBox(
//                             width: double.infinity,
//                             height: 52,
//                             child: ElevatedButton(
//                               onPressed: (_isLoading ||
//                                       _isGoogleLoading ||
//                                       _isFacebookLoading)
//                                   ? null
//                                   : _handleLogin,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: colorScheme.primary,
//                                 foregroundColor: colorScheme.onPrimary,
//                                 disabledBackgroundColor:
//                                     colorScheme.primary.withOpacity(0.5),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 elevation: 0,
//                               ),
//                               child: _isLoading
//                                   ? const SizedBox(
//                                       height: 22,
//                                       width: 22,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2.5,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.white),
//                                       ),
//                                     )
//                                   : Text(
//                                       t.translate('loginButton'),
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         letterSpacing: 0.3,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // ── Divider ─────────────────────────────────────────────
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Divider(
//                           color: colorScheme.outlineVariant.withOpacity(0.5),
//                           thickness: 1,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           t.translate('loginOrContinueWith'),
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: colorScheme.onSurfaceVariant,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(
//                           color: colorScheme.outlineVariant.withOpacity(0.5),
//                           thickness: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // ── Social Buttons ──────────────────────────────────────
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _SocialButton(
//                           onPressed: (_isLoading ||
//                                   _isGoogleLoading ||
//                                   _isFacebookLoading)
//                               ? null
//                               : _handleEmailSignIn,
//                           child: Icon(
//                             Icons.email_outlined,
//                             color: colorScheme.onSurfaceVariant,
//                             size: 22,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _SocialButton(
//                           onPressed: (_isLoading ||
//                                   _isGoogleLoading ||
//                                   _isFacebookLoading)
//                               ? null
//                               : _handleFacebookSignIn,
//                           isLoading: _isFacebookLoading,
//                           child: Image.asset(
//                             "assets/icons/facebook_icon.png",
//                             width: 22,
//                             height: 22,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _SocialButton(
//                           onPressed: (_isLoading ||
//                                   _isGoogleLoading ||
//                                   _isFacebookLoading)
//                               ? null
//                               : _handleGoogleSignIn,
//                           isLoading: _isGoogleLoading,
//                           child: Image.asset(
//                             "assets/icons/google_icon.png",
//                             width: 22,
//                             height: 22,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // ── Register Link ───────────────────────────────────────
//                 Center(
//                   child: Wrap(
//                     crossAxisAlignment: WrapCrossAlignment.center,
//                     children: [
//                       Text(
//                         t.translate('loginNoAccount'),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.pushNamed(
//                             context, AppRoutes.registerScreen),
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.only(left: 4),
//                           minimumSize: const Size(0, 0),
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                         child: Text(
//                           t.translate('loginSignUp'),
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             color: colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Social Button Widget ─────────────────────────────────────────────────────

// class _SocialButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final Widget child;
//   final bool isLoading;

//   const _SocialButton({
//     required this.onPressed,
//     required this.child,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           height: 52,
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
//             border: Border.all(
//               color: colorScheme.outlineVariant.withOpacity(0.5),
//               width: 1,
//             ),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Center(
//             child: isLoading
//                 ? SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor:
//                           AlwaysStoppedAnimation<Color>(colorScheme.primary),
//                     ),
//                   )
//                 : child,
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/controllers/authentication/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final LoginController controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  // ============ ANIMATIONS ============
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============ INPUT DECORATION ============

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required ColorScheme colorScheme,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 4),
        child: Icon(prefixIcon, color: colorScheme.onSurfaceVariant, size: 20),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: const TextStyle(fontSize: 12, height: 1.2),
    );
  }

  Future<void> _submitLogin(AppLocalizations t) async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();
    await controller.handleLogin(t, formValid: isValid);
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient Header ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 36,
                  ),
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
                  child: Column(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D47A1).withOpacity(0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            "assets/icons/nextgen_logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.translate('loginWelcomeTitle'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.translate('loginSubtitle'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // ── Form Card ───────────────────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          Text(
                            t.translate('loginEmailLabel'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.emailController,
                            focusNode: controller.emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) => controller.validateEmail(v, t),
                            onFieldSubmitted: (_) =>
                                controller.passwordFocusNode.requestFocus(),
                            cursorHeight: 20,
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                            decoration: _inputDecoration(
                              hint: t.translate('loginEmailHint'),
                              prefixIcon: Icons.email_outlined,
                              colorScheme: colorScheme,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Text(
                            t.translate('loginPasswordLabel'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => TextFormField(
                              controller: controller.passwordController,
                              focusNode: controller.passwordFocusNode,
                              obscureText: controller.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              validator: (v) =>
                                  controller.validatePassword(v, t),
                              onFieldSubmitted: (_) => _submitLogin(t),
                              cursorHeight: 20,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                              decoration: _inputDecoration(
                                hint: t.translate('loginPasswordHint'),
                                prefixIcon: Icons.lock_outlined,
                                colorScheme: colorScheme,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed(
                                  AppRoutes.forgetPasswordScreen),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                t.translate('loginForgotPassword'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: controller.anyLoading
                                    ? null
                                    : () => _submitLogin(t),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  disabledBackgroundColor:
                                      colorScheme.primary.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        t.translate('loginButton'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Divider ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          t.translate('loginOrContinueWith'),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Social Buttons ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            onPressed: controller.anyLoading
                                ? null
                                : controller.handleEmailSignIn,
                            child: Icon(
                              Icons.email_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            onPressed: controller.anyLoading
                                ? null
                                : () => controller.handleFacebookSignIn(t),
                            isLoading: controller.isFacebookLoading.value,
                            child: Image.asset(
                              "assets/icons/facebook_icon.png",
                              width: 22,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            onPressed: controller.anyLoading
                                ? null
                                : () => controller.handleGoogleSignIn(t),
                            isLoading: controller.isGoogleLoading.value,
                            child: Image.asset(
                              "assets/icons/google_icon.png",
                              width: 22,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Register Link ───────────────────────────────────────
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        t.translate('loginNoAccount'),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.registerScreen),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 4),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t.translate('loginSignUp'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Button Widget ─────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const _SocialButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}