import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hairsaloon/src/features/business_profile/domain/entities/business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/domain/repositories/business_profile_repository.dart';

class SyncedBusinessProfileRepository implements BusinessProfileRepository {
  SyncedBusinessProfileRepository({
    required BusinessProfileRepository local,
    required FirebaseFirestore firestore,
  }) : _local = local,
       _firestore = firestore;

  static const String collectionName = 'businessProfiles';

  final BusinessProfileRepository _local;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(collectionName);

  @override
  Future<BusinessProfile?> getProfile() => _local.getProfile();

  @override
  Future<void> saveProfile(BusinessProfile profile) async {
    await _local.saveProfile(profile);
    final key = _keyFromPhone(profile.phoneNumber);
    await _col.doc(key).set({
      'businessName': profile.businessName,
      'phoneNumber': profile.phoneNumber,
      'businessType': profile.businessType,
      'city': profile.city,
      'area': profile.area,
      'address': profile.address,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> clearProfile() async {
    final existing = await _local.getProfile();
    await _local.clearProfile();
    if (existing == null) return;
    final key = _keyFromPhone(existing.phoneNumber);
    await _col.doc(key).delete();
  }

  String _keyFromPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9+]'), '');
}

