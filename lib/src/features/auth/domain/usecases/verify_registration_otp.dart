import 'package:hairsaloon/src/features/auth/domain/repositories/auth_repository.dart';

class VerifyRegistrationOtp {
  const VerifyRegistrationOtp(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.verifyRegistrationOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}

