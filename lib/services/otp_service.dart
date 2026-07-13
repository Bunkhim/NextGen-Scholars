

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// OTP Service for Phone Authentication
/// Uses Firebase Phone Auth to send real SMS codes
class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  int? _resendToken;

  // ============ SEND OTP ============
  
  /// Send OTP code to phone number via SMS
  /// 
  /// [phoneNumber] must include country code (e.g., +855 12 345 678)
  /// 
  /// Callbacks:
  /// - [onCodeSent]: Called when SMS is sent successfully
  /// - [onError]: Called when sending fails
  /// - [onAutoVerify]: Called if phone is auto-verified
  Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(PhoneAuthCredential credential) onAutoVerify,
  }) async {
    try {
      debugPrint('📱 Sending OTP to: $phoneNumber');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        
        // Success: SMS sent
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ OTP Code Sent Successfully!');
          debugPrint('   Verification ID: $verificationId');
          
          _verificationId = verificationId;
          _resendToken = resendToken;
          
          onCodeSent(verificationId);
        },
        
        // Auto verification completed (instant)
        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('✅ Auto Verification Complete!');
          debugPrint('   Phone verified instantly');
          
          onAutoVerify(credential);
        },
        
        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification Failed!');
          debugPrint('   Code: ${e.code}');
          debugPrint('   Message: ${e.message}');
          
          String errorMessage = _getErrorMessage(e.code);
          onError(errorMessage);
        },
        
        // Code auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Auto-retrieval Timeout');
          _verificationId = verificationId;
        },
        
        // Timeout duration (60 seconds)
        timeout: const Duration(seconds: 60),
      );
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Exception sending OTP: $e');
      onError('Failed to send OTP: $e');
      return false;
    }
  }
  
  // ============ VERIFY OTP ============
  
  /// Verify the OTP code entered by user
  /// 
  /// [otp]: 6-digit code from SMS
  /// [verificationId]: ID from onCodeSent callback (optional if using same instance)
  /// 
  /// Returns:
  /// - success: true/false
  /// - message: Success or error message
  /// - user: Firebase user object (if successful)
  Future<Map<String, dynamic>> verifyOTP({
    required String otp,
    String? verificationId,
  }) async {
    try {
      debugPrint('🔍 Verifying OTP: $otp');
      
      final String vId = verificationId ?? _verificationId ?? '';
      
      if (vId.isEmpty) {
        debugPrint('❌ Verification ID is empty!');
        return {
          'success': false,
          'message': 'Verification ID not found. Please resend OTP.',
        };
      }
      
      // Create phone auth credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: otp,
      );
      
      debugPrint('🔐 Signing in with credential...');
      
      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('✅ Verification Successful!');
      debugPrint('   User ID: ${userCredential.user?.uid}');
      debugPrint('   Phone: ${userCredential.user?.phoneNumber}');
      
      return {
        'success': true,
        'message': 'Verification successful!',
        'user': userCredential.user,
      };
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Exception!');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      
      String errorMessage = _getVerifyErrorMessage(e.code);
      
      return {
        'success': false,
        'message': errorMessage,
      };
      
    } catch (e) {
      debugPrint('❌ Exception verifying OTP: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
  
  // ============ RESEND OTP ============
  
  /// Resend OTP code to the same phone number
  /// 
  /// Uses forceResendingToken to allow immediate resend
  Future<bool> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      debugPrint('🔄 Resending OTP to: $phoneNumber');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ OTP Resent Successfully!');
          
          _verificationId = verificationId;
          _resendToken = resendToken;
          
          onCodeSent(verificationId);
        },
        
        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('✅ Auto-verified on resend');
        },
        
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Resend Failed: ${e.message}');
          String errorMessage = _getErrorMessage(e.code);
          onError(errorMessage);
        },
        
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        
        timeout: const Duration(seconds: 60),
      );
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Exception resending OTP: $e');
      onError('Failed to resend OTP: $e');
      return false;
    }
  }
  
  // ============ ERROR MESSAGES ============
  
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Please include country code (e.g., +855)';
      
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support';
      
      default:
        return 'Failed to send OTP. Please try again';
    }
  }
  
  String _getVerifyErrorMessage(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again';
      
      case 'session-expired':
        return 'OTP code expired. Please request a new code';
      
      case 'invalid-verification-id':
        return 'Verification session invalid. Please request a new code';
      
      case 'credential-already-in-use':
        return 'This phone number is already registered';
      
      default:
        return 'Verification failed. Please try again';
    }
  }
  
  // ============ UTILITY METHODS ============
  
  /// Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }
}