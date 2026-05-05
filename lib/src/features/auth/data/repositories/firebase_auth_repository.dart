import 'package:hairsaloon/src/features/auth/data/datasources/firebase_phone_otp_datasource.dart';
import 'package:hairsaloon/src/features/auth/data/datasources/firestore_users_datasource.dart';
import 'package:hairsaloon/src/features/auth/data/datasources/local_auth_session_datasource.dart';
import 'package:hairsaloon/src/features/auth/domain/entities/app_user.dart';
import 'package:hairsaloon/src/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required LocalAuthSessionDataSource session,
    required FirebasePhoneOtpDataSource otp,
    required FirestoreUsersDataSource users,
  }) : _session = session,
       _otp = otp,
       _users = users;

  final LocalAuthSessionDataSource _session;
  final FirebasePhoneOtpDataSource _otp;
  final FirestoreUsersDataSource _users;

  @override
  Future<bool> hasSession() async {
    final id = _session.readUserId();
    return id != null && id.trim().isNotEmpty;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final id = _session.readUserId();
    if (id == null || id.trim().isEmpty) return null;
    return _users.getUserById(id);
  }

  @override
  Future<OtpSession> sendRegistrationOtp({required String phone}) async {
    final verificationId = await _otp.sendOtp(phone: phone);
    return OtpSession(verificationId: verificationId);
  }

  @override
  Future<void> verifyRegistrationOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    await _otp.verifyOtp(verificationId: verificationId, smsCode: smsCode);
  }

  @override
  Future<AppUser> registerUser({
    required String name,
    required String phone,
    required String password,
  }) async {
    final user = await _users.createUser(name: name, phone: phone, password: password);
    await _session.writeUserId(user.id);
    await _otp.signOut();
    return user;
  }

  @override
  Future<AppUser> loginWithPhonePassword({
    required String phone,
    required String password,
  }) async {
    final user = await _users.login(phone: phone, password: password);
    await _session.writeUserId(user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    await _session.clear();
    await _otp.signOut();
  }
}

