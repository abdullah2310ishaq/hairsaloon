import 'package:hairsaloon/src/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<bool> hasSession();
  Future<AppUser?> getCurrentUser();

  Future<OtpSession> sendRegistrationOtp({required String phone});
  Future<void> verifyRegistrationOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<AppUser> registerUser({
    required String name,
    required String phone,
    required String password,
  });

  Future<AppUser> loginWithPhonePassword({
    required String phone,
    required String password,
  });

  Future<void> logout();
}

class OtpSession {
  const OtpSession({required this.verificationId});

  final String verificationId;
}

