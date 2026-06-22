import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePaths {
  FirestorePaths({
    required FirebaseFirestore firestore,
    required this.userId,
    required this.businessId,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final String userId;
  final String businessId;

  DocumentReference<Map<String, dynamic>> get userDoc =>
      _firestore.collection('users').doc(userId);

  DocumentReference<Map<String, dynamic>> get businessDoc =>
      userDoc.collection('businesses').doc(businessId);

  DocumentReference<Map<String, dynamic>> get profileDoc =>
      businessDoc.collection('meta').doc('profile');

  DocumentReference<Map<String, dynamic>> get settingsDoc =>
      businessDoc.collection('meta').doc('settings');

  CollectionReference<Map<String, dynamic>> col(String name) =>
      businessDoc.collection(name);
}

