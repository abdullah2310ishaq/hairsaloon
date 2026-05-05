import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneOtpDataSource {
  FirebasePhoneOtpDataSource({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<String> sendOtp({required String phone}) async {
    final completer = Completer<String>();
    final normalized = _normalizePhone(phone);

    await _auth.verifyPhoneNumber(
      phoneNumber: normalized,
      verificationCompleted: (credential) async {
        // Auto-retrieval on some devices; treat as verified but we still need
        // a verificationId for manual flow. If we can't, we just ignore and let
        // codeSent handle.
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      timeout: const Duration(seconds: 60),
    );

    return completer.future;
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}

