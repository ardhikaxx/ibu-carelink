import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/kick_session_model.dart';

abstract class KickCounterRemoteDataSource {
  Future<KickSessionModel> saveSession(KickSessionModel session, String userId);
  Future<List<KickSessionModel>> getSessions(String userId, String pregnancyId);
}

class KickCounterRemoteDataSourceImpl implements KickCounterRemoteDataSource {
  final FirebaseFirestore firestore;
  KickCounterRemoteDataSourceImpl({required this.firestore});

  @override
  Future<KickSessionModel> saveSession(KickSessionModel session, String userId) async {
    try {
      final ref = firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .doc(session.pregnancyId)
          .collection('kick_counts')
          .doc(session.id);
      await ref.set(session.toFirestore());
      return session;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<KickSessionModel>> getSessions(String userId, String pregnancyId) async {
    try {
      final snap = await firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .doc(pregnancyId)
          .collection('kick_counts')
          .orderBy('startTime', descending: true)
          .get();
      return snap.docs
          .map((doc) => KickSessionModel.fromFirestore(doc.data(), doc.id, pregnancyId))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
