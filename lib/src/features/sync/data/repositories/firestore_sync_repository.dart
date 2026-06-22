import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hairsaloon/src/features/sync/data/firestore_paths.dart';

class FirestoreSyncRepository {
  FirestoreSyncRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensureRoots({
    required String userId,
    required String businessId,
    required Map<String, dynamic> profileData,
  }) async {
    final paths = FirestorePaths(
      firestore: _firestore,
      userId: userId,
      businessId: businessId,
    );

    await paths.userDoc.set(
      <String, dynamic>{
        'id': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await paths.businessDoc.set(
      <String, dynamic>{
        'id': businessId,
        'phoneNumber': profileData['phoneNumber'],
        'businessName': profileData['businessName'],
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> upsertProfile({
    required String userId,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    final paths = FirestorePaths(
      firestore: _firestore,
      userId: userId,
      businessId: businessId,
    );
    await paths.profileDoc.set(
      <String, dynamic>{
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> upsertSettings({
    required String userId,
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    final paths = FirestorePaths(
      firestore: _firestore,
      userId: userId,
      businessId: businessId,
    );
    await paths.settingsDoc.set(
      <String, dynamic>{
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> upsertCollection({
    required String userId,
    required String businessId,
    required String collectionName,
    required List<SyncDoc> docs,
    void Function(int done, int total)? onProgress,
  }) async {
    final paths = FirestorePaths(
      firestore: _firestore,
      userId: userId,
      businessId: businessId,
    );
    final col = paths.col(collectionName);
    final metaRef = col.doc('_meta');

    if (docs.isEmpty) {
      await metaRef.set(
        <String, dynamic>{
          'count': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      onProgress?.call(0, 0);
      return;
    }

    const maxWritesPerBatch = 450;
    var done = 0;
    final total = docs.length;

    for (var i = 0; i < docs.length; i += maxWritesPerBatch) {
      final chunk = docs.sublist(
        i,
        (i + maxWritesPerBatch) > docs.length ? docs.length : (i + maxWritesPerBatch),
      );

      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.set(
          col.doc(doc.id),
          <String, dynamic>{
            ...doc.data,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();

      done += chunk.length;
      onProgress?.call(done, total);
    }

    await metaRef.set(
      <String, dynamic>{
        'count': total,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

class SyncDoc {
  const SyncDoc({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

