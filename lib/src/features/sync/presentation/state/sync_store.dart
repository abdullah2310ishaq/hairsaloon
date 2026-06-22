import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hairsaloon/src/core/storage/hive_boxes.dart';
import 'package:hairsaloon/src/features/auth/presentation/state/auth_store.dart';
import 'package:hairsaloon/src/features/business_profile/domain/entities/business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/presentation/state/business_profile_notifier.dart';
import 'package:hairsaloon/src/features/sync/data/repositories/firestore_sync_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SyncStore extends ChangeNotifier {
  SyncStore({required FirestoreSyncRepository repository}) : _repository = repository;

  final FirestoreSyncRepository _repository;

  AuthStore? _auth;
  BusinessProfileNotifier? _profile;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  bool _isMinimized = false;
  bool get isMinimized => _isMinimized;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  SyncPhase _phase = SyncPhase.idle;
  SyncPhase get phase => _phase;

  int _done = 0;
  int get done => _done;

  int _total = 0;
  int get total => _total;

  String? _error;
  String? get error => _error;

  DateTime? _lastSuccessAt;
  DateTime? get lastSuccessAt => _lastSuccessAt;

  bool _completionNotified = false;
  bool get completionNotified => _completionNotified;

  bool get isRunning => _status == SyncStatus.running;

  void updateContext({
    required AuthStore auth,
    required BusinessProfileNotifier profile,
  }) {
    _auth = auth;
    _profile = profile;
  }

  void expand() {
    _isExpanded = true;
    _isMinimized = false;
    notifyListeners();
  }

  void minimize() {
    _isExpanded = false;
    _isMinimized = true;
    notifyListeners();
  }

  void dismiss() {
    _isExpanded = false;
    _isMinimized = false;
    if (_status != SyncStatus.running) {
      _status = SyncStatus.idle;
      _phase = SyncPhase.idle;
      _done = 0;
      _total = 0;
      _error = null;
    }
    notifyListeners();
  }

  Future<void> startSync() async {
    if (_status == SyncStatus.running) {
      expand();
      return;
    }
    expand();

    final userId = _auth?.currentUser?.id;
    final profile = _profile?.profile;
    if (userId == null || userId.trim().isEmpty) {
      _fail('Not logged in. Please login again.');
      return;
    }
    if (profile == null) {
      _fail('Business profile not found. Please complete business registration.');
      return;
    }

    final businessId = _normalizePhone(profile.phoneNumber);
    if (businessId.isEmpty) {
      _fail('Business phone is missing. Please update business profile.');
      return;
    }

    _status = SyncStatus.running;
    _error = null;
    _phase = SyncPhase.profile;
    _done = 0;
    _total = 0;
    _completionNotified = false;
    notifyListeners();

    try {
      final profileMap = _profileToMap(profile);
      await _repository.ensureRoots(
        userId: userId,
        businessId: businessId,
        profileData: profileMap,
      );
      await _repository.upsertProfile(
        userId: userId,
        businessId: businessId,
        data: profileMap,
      );

      await _syncSettings(userId: userId, businessId: businessId);
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.employees,
        collection: 'employees',
        boxName: HiveBoxes.employees,
      );
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.bills,
        collection: 'bills',
        boxName: HiveBoxes.bills,
      );
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.expenses,
        collection: 'expenses',
        boxName: HiveBoxes.expenses,
      );
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.services,
        collection: 'services',
        boxName: HiveBoxes.services,
      );
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.categories,
        collection: 'categories',
        boxName: HiveBoxes.categories,
      );
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.payouts,
        collection: 'employeePayouts',
        boxName: HiveBoxes.employeePayouts,
      );
      await _syncStringBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.customerPhones,
        collection: 'customerPhones',
        boxName: HiveBoxes.customerPhones,
      );
      await _syncBoxAsCollection(
        userId: userId,
        businessId: businessId,
        phase: SyncPhase.customerContacts,
        collection: 'customerContacts',
        boxName: HiveBoxes.customerContacts,
      );

      _status = SyncStatus.success;
      _phase = SyncPhase.done;
      _lastSuccessAt = DateTime.now();
      notifyListeners();
    } catch (e) {
      _fail(e.toString());
    }
  }

  void markCompletionNotified() {
    if (_completionNotified) return;
    _completionNotified = true;
    notifyListeners();
  }

  void _fail(String message) {
    _status = SyncStatus.failure;
    _error = message;
    _completionNotified = false;
    notifyListeners();
  }

  Future<void> _syncSettings({
    required String userId,
    required String businessId,
  }) async {
    _phase = SyncPhase.settings;
    _done = 0;
    _total = 0;
    notifyListeners();

    final settingsBox = Hive.box<dynamic>(HiveBoxes.settings);
    final map = <String, dynamic>{};
    for (final entry in settingsBox.toMap().entries) {
      map[entry.key.toString()] = entry.value;
    }
    await _repository.upsertSettings(
      userId: userId,
      businessId: businessId,
      data: map,
    );
  }

  Future<void> _syncBoxAsCollection({
    required String userId,
    required String businessId,
    required SyncPhase phase,
    required String collection,
    required String boxName,
  }) async {
    _phase = phase;
    notifyListeners();

    final box = Hive.box<Map>(boxName);
    final entries = box.toMap().entries.toList(growable: false);
    _done = 0;
    _total = entries.length;
    notifyListeners();

    final docs = entries.map((e) {
      final id = e.key.toString();
      final raw = Map<String, dynamic>.from(e.value);
      raw['id'] ??= id;
      return SyncDoc(id: id, data: raw);
    }).toList(growable: false);

    await _repository.upsertCollection(
      userId: userId,
      businessId: businessId,
      collectionName: collection,
      docs: docs,
      onProgress: (done, total) {
        _done = done;
        _total = total;
        notifyListeners();
      },
    );
  }

  Future<void> _syncStringBoxAsCollection({
    required String userId,
    required String businessId,
    required SyncPhase phase,
    required String collection,
    required String boxName,
  }) async {
    _phase = phase;
    notifyListeners();

    final box = Hive.box<String>(boxName);
    final entries = box.toMap().entries.toList(growable: false);
    _done = 0;
    _total = entries.length;
    notifyListeners();

    final docs = entries
        .map(
          (e) => SyncDoc(
            id: e.key.toString(),
            data: <String, dynamic>{'value': e.value},
          ),
        )
        .toList(growable: false);

    await _repository.upsertCollection(
      userId: userId,
      businessId: businessId,
      collectionName: collection,
      docs: docs,
      onProgress: (done, total) {
        _done = done;
        _total = total;
        notifyListeners();
      },
    );
  }

  static Map<String, dynamic> _profileToMap(BusinessProfile profile) {
    return <String, dynamic>{
      'businessName': profile.businessName,
      'phoneNumber': profile.phoneNumber,
      'businessType': profile.businessType,
      'city': profile.city,
      'area': profile.area,
      'address': profile.address,
    };
  }

  static String _normalizePhone(String value) =>
      value.replaceAll(RegExp(r'[^0-9+]'), '').trim();
}

enum SyncStatus { idle, running, success, failure }

enum SyncPhase {
  idle,
  profile,
  settings,
  employees,
  bills,
  expenses,
  services,
  categories,
  payouts,
  customerPhones,
  customerContacts,
  done,
}

