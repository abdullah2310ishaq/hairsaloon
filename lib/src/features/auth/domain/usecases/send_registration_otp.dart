import 'package:hairsaloon/src/features/auth/domain/repositories/auth_repository.dart';

class SendRegistrationOtp {
  const SendRegistrationOtp(this._repository);

  final AuthRepository _repository;

  Future<OtpSession> call({required String phone}) {
    return _repository.sendRegistrationOtp(phone: phone);
  }
}

