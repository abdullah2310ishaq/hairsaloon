import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hairsaloon/src/features/business_profile/data/models/business_profile_model.dart';
import 'package:hairsaloon/src/features/business_profile/domain/entities/business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/domain/repositories/business_profile_repository.dart';

class FirestoreBusinessProfileRepository implements BusinessProfileRepository {
  FirestoreBusinessProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String collectionName = 'businessProfiles';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(collectionName);

  @override
  Future<BusinessProfile?> getProfile() async {
    // Remote read is not used as source of truth for now (local-first app).
    return null;
  }

  @override
  Future<void> saveProfile(BusinessProfile profile) async {
    final key = _keyFromPhone(profile.phoneNumber);
    await _col.doc(key).set(
      BusinessProfileModel.fromEntity(profile).toJsonMap(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> clearProfile() async {
    // No-op; remote delete requires a key (phone). We delete remotely from the
    // composite repository where we have the last stored local profile.
  }

  String _keyFromPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9+]'), '');
}

