import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:hairsaloon/src/features/auth/domain/entities/app_user.dart';

class FirestoreUsersDataSource {
  FirestoreUsersDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String collectionName = 'users';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(collectionName);

  Future<AppUser?> getUserById(String id) async {
    final snap = await _users.doc(id).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return _fromDoc(id, data);
  }

  Future<_UserRecord?> getUserRecordByPhone(String phone) async {
    final query = await _users.where('phone', isEqualTo: phone).limit(1).get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final data = doc.data();
    return _UserRecord(
      id: doc.id,
      user: _fromDoc(doc.id, data),
      passwordHash: (data['passwordHash'] as String?) ?? '',
      passwordSalt: (data['passwordSalt'] as String?) ?? '',
    );
  }

  Future<String> generateUniqueUsername(String name) async {
    final first = _firstNameBase(name);
    final rng = Random.secure();
    for (var i = 0; i < 12; i++) {
      final suffix = (rng.nextInt(9000) + 1000).toString();
      final candidate = '$first$suffix';
      final exists = await _usernameExists(candidate);
      if (!exists) return candidate;
    }
    final fallback = '${first}${DateTime.now().millisecondsSinceEpoch % 100000}';
    return fallback;
  }

  Future<AppUser> createUser({
    required String name,
    required String phone,
    required String password,
  }) async {
    final existing = await getUserRecordByPhone(phone);
    if (existing != null) {
      throw StateError('User already exists with this phone number.');
    }

    final username = await generateUniqueUsername(name);
    final salt = _randomSalt();
    final hash = _hashPassword(password: password, salt: salt);

    final now = DateTime.now();
    final doc = await _users.add({
      'name': name,
      'username': username,
      'phone': phone,
      'passwordHash': hash,
      'passwordSalt': salt,
      'createdAt': Timestamp.fromDate(now),
    });

    return AppUser(
      id: doc.id,
      name: name,
      username: username,
      phone: phone,
      createdAt: now,
    );
  }

  Future<AppUser> login({
    required String phone,
    required String password,
  }) async {
    final record = await getUserRecordByPhone(phone);
    if (record == null) {
      throw StateError('No user found for this phone number.');
    }

    final expected = record.passwordHash;
    final salt = record.passwordSalt;
    final actual = _hashPassword(password: password, salt: salt);
    if (expected.isEmpty || salt.isEmpty || actual != expected) {
      throw StateError('Invalid password.');
    }
    return record.user;
  }

  AppUser _fromDoc(String id, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0);

    return AppUser(
      id: id,
      name: (data['name'] as String?) ?? '',
      username: (data['username'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      createdAt: createdAt,
    );
  }

  String _firstNameBase(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final first = cleaned.isEmpty ? 'user' : cleaned.split(' ').first;
    final normalized = first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.isEmpty ? 'user' : normalized;
  }

  Future<bool> _usernameExists(String username) async {
    final q = await _users.where('username', isEqualTo: username).limit(1).get();
    return q.docs.isNotEmpty;
  }

  String _randomSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPassword({required String password, required String salt}) {
    final bytes = sha256.convert('$salt$password'.codeUnits).bytes;
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

class _UserRecord {
  const _UserRecord({
    required this.id,
    required this.user,
    required this.passwordHash,
    required this.passwordSalt,
  });

  final String id;
  final AppUser user;
  final String passwordHash;
  final String passwordSalt;
}

