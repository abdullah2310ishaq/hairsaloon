import 'package:flutter/foundation.dart';
import 'package:hairsaloon/src/features/auth/domain/entities/app_user.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/get_current_user.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/has_session.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/login_with_phone_password.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/logout.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/register_user.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/send_registration_otp.dart';
import 'package:hairsaloon/src/features/auth/domain/usecases/verify_registration_otp.dart';

class AuthStore extends ChangeNotifier {
  AuthStore({
    required HasSession hasSession,
    required GetCurrentUser getCurrentUser,
    required SendRegistrationOtp sendRegistrationOtp,
    required VerifyRegistrationOtp verifyRegistrationOtp,
    required RegisterUser registerUser,
    required LoginWithPhonePassword loginWithPhonePassword,
    required Logout logout,
  }) : _hasSession = hasSession,
       _getCurrentUser = getCurrentUser,
       _sendRegistrationOtp = sendRegistrationOtp,
       _verifyRegistrationOtp = verifyRegistrationOtp,
       _registerUser = registerUser,
       _loginWithPhonePassword = loginWithPhonePassword,
       _logout = logout;

  final HasSession _hasSession;
  final GetCurrentUser _getCurrentUser;
  final SendRegistrationOtp _sendRegistrationOtp;
  final VerifyRegistrationOtp _verifyRegistrationOtp;
  final RegisterUser _registerUser;
  final LoginWithPhonePassword _loginWithPhonePassword;
  final Logout _logout;

  bool _isLoading = false;
  String? _error;
  AppUser? _currentUser;

  String? _pendingVerificationId;
  _PendingRegistration? _pendingRegistration;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AppUser? get currentUser => _currentUser;
  bool get hasPendingOtp => _pendingVerificationId != null;

  Future<bool> hasLocalSession() => _hasSession();

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startRegistration({
    required String name,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _pendingRegistration = _PendingRegistration(
        name: name,
        phone: phone,
        password: password,
      );
      final session = await _sendRegistrationOtp(phone: phone);
      _pendingVerificationId = session.verificationId;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _pendingRegistration = null;
      _pendingVerificationId = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmRegistrationOtp({required String smsCode}) async {
    final verificationId = _pendingVerificationId;
    final pending = _pendingRegistration;
    if (verificationId == null || pending == null) {
      _error = 'Registration session expired. Please try again.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _verifyRegistrationOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      _currentUser = await _registerUser(
        name: pending.name,
        phone: pending.phone,
        password: pending.password,
      );
      _error = null;
      _pendingVerificationId = null;
      _pendingRegistration = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String phone, required String password}) async {
    _setLoading(true);
    try {
      _currentUser = await _loginWithPhonePassword(phone: phone, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _logout();
      _currentUser = null;
      _error = null;
      _pendingRegistration = null;
      _pendingVerificationId = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class _PendingRegistration {
  const _PendingRegistration({
    required this.name,
    required this.phone,
    required this.password,
  });

  final String name;
  final String phone;
  final String password;
}

