import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/contraction_model.dart';

abstract class ContractionRemoteDataSource {
  Future<ContractionModel> saveContraction(ContractionModel contraction, String userId);
  Future<List<ContractionModel>> getContractions(String userId, String pregnancyId);
}

class ContractionRemoteDataSourceImpl implements ContractionRemoteDataSource {
  final FirebaseFirestore firestore;
  ContractionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ContractionModel> saveContraction(ContractionModel contraction, String userId) async {
    try {
      final ref = firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .doc(contraction.pregnancyId)
          .collection('contractions')
          .doc(contraction.id);
      await ref.set(contraction.toFirestore());
      return contraction;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ContractionModel>> getContractions(String userId, String pregnancyId) async {
    try {
      final snap = await firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .doc(pregnancyId)
          .collection('contractions')
          .orderBy('startTime', descending: true)
          .get();
      return snap.docs
          .map((doc) => ContractionModel.fromFirestore(doc.data(), doc.id, pregnancyId))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
